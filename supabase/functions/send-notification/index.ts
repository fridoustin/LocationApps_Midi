import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

// Interface dan inisialisasi Supabase tetap sama
interface NotificationPayload {
  type: 'INSERT';
  table: string;
  record: { id: string; user_id: string; ulok_id: string; type: string; };
}

const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!;
const FCM_V1_URL = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

// --- MENGGUNAKAN FUNGSI getAccessToken DARI CONTOH TEMAN ANDA ---
// Diadaptasi untuk membaca dari Supabase Secrets, bukan file import
async function getAccessToken(): Promise<string> {
  // Ambil kredensial dari environment variable yang aman
  const serviceAccount = JSON.parse(Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON')!);

  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(new Error(`Authorization failed: ${err.message}`));
        return;
      }
      if (!tokens?.access_token) {
        reject(new Error('Failed to retrieve access token.'));
        return;
      }
      resolve(tokens.access_token);
    });
  });
}

// --- FUNGSI UTAMA (Sama seperti sebelumnya, hanya menggunakan getAccessToken yang baru) ---

Deno.serve(async (req) => {
  const payload: NotificationPayload = await req.json();
  const { record } = payload;

  try {
    // 1. Ambil detail yang dibutuhkan (tidak berubah)
    const { data: userData, error: userError } = await supabaseAdmin
      .from('users').select('fcm_token').eq('id', record.user_id).single();
    if (userError || !userData?.fcm_token) throw new Error(`User or FCM token not found for user: ${record.user_id}`);
    
    const { data: ulokData, error: ulokError } = await supabaseAdmin
      .from('ulok').select('nama_ulok, approval_status').eq('id', record.ulok_id).single();
    if (ulokError) throw new Error(`ULOK not found for id: ${record.ulok_id}`);

    // 2. Tentukan isi notifikasi (tidak berubah)
    let title = '', body = '', dataPayload = {};
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
          return new Response(JSON.stringify({ status: "skipped" }), { headers: { 'Content-Type': 'application/json' }});
        }
        break;
    }
    
    // 3. Kirim notifikasi ke Firebase (tidak berubah)
    const accessToken = await getAccessToken();
    const fcmV1Payload = {
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
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmV1Payload),
    });
    if (!fcmResponse.ok) {
        const errorBody = await fcmResponse.json();
        throw new Error(`FCM request failed: ${JSON.stringify(errorBody)}`);
    }

    // 4. Update baris notifikasi (tidak berubah)
    await supabaseAdmin.from('notifications').update({ title, body }).eq('id', record.id);

    return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' } });
  } catch (error) {
    console.error('Function Error:', error.message);
    return new Response(JSON.stringify({ success: false, error: error.message }), { status: 500 });
  }
});