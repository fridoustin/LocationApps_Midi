import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!;
const GOOGLE_SERVICE_ACCOUNT_JSON = JSON.parse(Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON')!);

const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

const FCM_V1_URL = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

async function getAccessToken(): Promise<string> {
  const jwtClient = new JWT({
    email: GOOGLE_SERVICE_ACCOUNT_JSON.client_email,
    key: GOOGLE_SERVICE_ACCOUNT_JSON.private_key.replace(/\\n/g, '\n'),
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });

  const tokens = await new Promise<{ access_token?: string }>((resolve, reject) =>
    jwtClient.authorize((err, t) => (err ? reject(err) : resolve(t)))
  );

  if (!tokens?.access_token) throw new Error('Failed to retrieve access token.');
  return tokens.access_token;
}

Deno.serve(async (req) => {
  try {
    // hanya izinkan POST
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'Method not allowed. Use POST.' }),
        { status: 405, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const contentType = req.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
      return new Response(
        JSON.stringify({ success: false, error: 'Content-Type must be application/json' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // parse payload dari webhook
    const payload = await req.json();
    const record = payload?.record;
    if (!record) {
      return new Response(
        JSON.stringify({ success: false, error: 'Payload missing record' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // ambil FCM token user
    const { data: userData, error: userError } = await supabaseAdmin
      .from('users')
      .select('fcm_token')
      .eq('id', record.user_id)
      .maybeSingle();
    if (userError) throw userError;
    if (!userData?.fcm_token)
      throw new Error(`User or FCM token not found for user: ${record.user_id}`);

    // ambil data ulok
    const { data: ulokData, error: ulokError } = await supabaseAdmin
      .from('ulok')
      .select('nama_ulok, approval_status')
      .eq('id', record.ulok_id)
      .maybeSingle();
    if (ulokError) throw ulokError;

    // bangun title & body sesuai status
    let title = '';
    let body = '';
    let dataPayload: Record<string, string> = {};

    if (record.type === 'ULOK_STATUS_UPDATE') {
      if (ulokData.approval_status === 'OK') {
        title = 'ULOK Disetujui!';
        body = `ULOK "${ulokData.nama_ulok}" telah disetujui. Silakan isi data tambahan untuk KPLT.`;
        dataPayload = { screen: '/form-kplt', ulokId: record.ulok_id };
      } else if (ulokData.approval_status === 'NOK') {
        title = 'ULOK Ditolak';
        body = `ULOK "${ulokData.nama_ulok}" telah ditolak.`;
      } else {
        return new Response(JSON.stringify({ status: 'skipped' }), {
          headers: { 'Content-Type': 'application/json' },
        });
      }
    } else {
      title = 'Perubahan Data ULOK';
      body = `Ada pembaruan pada ULOK "${ulokData.nama_ulok}".`;
    }

    // kirim ke Firebase
    const accessToken = await getAccessToken();
    const fcmPayload = {
      message: {
        token: userData.fcm_token,
        notification: { title, body },
        data: dataPayload,
      },
    };

    const fcmResponse = await fetch(FCM_V1_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    if (!fcmResponse.ok) {
      const errorBody = await fcmResponse.text();
      throw new Error(`FCM request failed: ${errorBody}`);
    }

    // update tabel notifications dengan title & body
    await supabaseAdmin.from('notifications').update({ title, body }).eq('id', record.id);

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err: any) {
    console.error('Handler error:', err?.message ?? err);
    return new Response(
      JSON.stringify({ success: false, error: err?.message ?? String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
