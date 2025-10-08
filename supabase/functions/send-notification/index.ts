import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

// === ENV SETUP ===
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!;
const GOOGLE_SERVICE_ACCOUNT_JSON = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON')!;

// === SUPABASE CLIENT ===
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});
const FCM_V1_URL = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

// === FIREBASE ACCESS TOKEN ===
async function getAccessToken(): Promise<string> {
  const serviceAccountRaw = JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON);
  if (typeof serviceAccountRaw.private_key === 'string') {
    serviceAccountRaw.private_key = serviceAccountRaw.private_key.replace(/\\n/g, '\n');
  }
  const jwtClient = new JWT({
    email: serviceAccountRaw.client_email,
    key: serviceAccountRaw.private_key,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });

  return new Promise((resolve, reject) => {
    jwtClient.authorize((err, tokens) => {
      if (err) return reject(new Error(`Authorization failed: ${err.message}`));
      if (!tokens?.access_token) return reject(new Error('Failed to retrieve access token.'));
      resolve(tokens.access_token);
    });
  });
}

// === MAIN HANDLER ===
Deno.serve(async (req) => {
  try {
    // hanya izinkan POST
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'Method not allowed. Use POST.' }),
        { status: 405, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // pastikan content-type JSON
    const ct = req.headers.get('content-type') || '';
    if (!ct.includes('application/json')) {
      return new Response(
        JSON.stringify({ success: false, error: 'Content-Type must be application/json' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // parse body
    let payload: any;
    try {
      payload = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid or empty JSON body' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const record = payload?.record;
    if (!record) {
      return new Response(
        JSON.stringify({ success: false, error: 'Payload missing record field' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // === ambil data user & ulok ===
    const { data: userData, error: userError } = await supabaseAdmin
      .from('users')
      .select('fcm_token')
      .eq('id', record.user_id)
      .maybeSingle();
    if (userError) throw userError;
    if (!userData?.fcm_token)
      throw new Error(`User or FCM token not found for user: ${record.user_id}`);

    const { data: ulokData, error: ulokError } = await supabaseAdmin
      .from('ulok')
      .select('nama_ulok, approval_status')
      .eq('id', record.ulok_id)
      .maybeSingle();
    if (ulokError) throw ulokError;

    // === tentukan title & body seperti versi lama ===
    let title = '';
    let body = '';
    let dataPayload: Record<string, string> = {};

    switch (record.type) {
      case 'ULOK_STATUS_UPDATE':
        if (ulokData.approval_status === 'OK') {
          title = 'ULOK Disetujui!';
          body = `ULOK "${ulokData.nama_ulok}" telah disetujui. Silakan isi data tambahan untuk KPLT.`;
          dataPayload = { screen: '/form-kplt', ulokId: record.ulok_id };
        } else if (ulokData.approval_status === 'NOK') {
          title = 'ULOK Ditolak';
          body = `ULOK "${ulokData.nama_ulok}" telah ditolak.`;
        } else {
          // status lain: tidak kirim notifikasi
          return new Response(JSON.stringify({ status: 'skipped' }), {
            headers: { 'Content-Type': 'application/json' },
          });
        }
        break;
      default:
        title = 'Perubahan Data ULOK';
        body = `Data ULOK "${ulokData.nama_ulok}" telah diperbarui.`;
        break;
    }

    // === kirim notifikasi ke FCM ===
    const accessToken = await getAccessToken();
    const fcmPayload = {
      message: {
        token: userData.fcm_token,
        notification: { title, body },
        data: dataPayload,
      },
    };

    const fcmRes = await fetch(FCM_V1_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    if (!fcmRes.ok) {
      const txt = await fcmRes.text();
      throw new Error(`FCM request failed: ${txt}`);
    }

    // === update tabel notifikasi ===
    if (record.id) {
      await supabaseAdmin
        .from('notifications')
        .update({ title, body })
        .eq('id', record.id);
    }

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
