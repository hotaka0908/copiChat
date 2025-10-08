import { NextResponse } from 'next/server';

/**
 * 許可されたオリジンのリスト
 * 環境変数から動的に取得し、複数ドメインに対応
 */
function getAllowedOrigins(): string[] {
  const origins: string[] = [];

  // 開発環境
  if (process.env.NODE_ENV === 'development') {
    origins.push('http://localhost:3000');
    origins.push('http://127.0.0.1:3000');
  }

  // 本番環境のドメイン（環境変数から取得）
  if (process.env.NEXT_PUBLIC_APP_URL) {
    origins.push(process.env.NEXT_PUBLIC_APP_URL);
  }

  // Vercelプレビューデプロイメント（自動検出）
  // VERCEL_URLにはhttps://が含まれていないため追加
  if (process.env.VERCEL_URL) {
    origins.push(`https://${process.env.VERCEL_URL}`);
  }

  // VercelのプロダクションURL（NEXT_PUBLIC_VERCEL_URL）
  if (process.env.NEXT_PUBLIC_VERCEL_URL) {
    origins.push(`https://${process.env.NEXT_PUBLIC_VERCEL_URL}`);
  }

  return origins;
}

/**
 * リクエストのオリジンが許可されているかチェック
 */
export function isOriginAllowed(origin: string | null): boolean {
  if (!origin) return false;

  const allowedOrigins = getAllowedOrigins();

  // 完全一致チェック
  if (allowedOrigins.includes(origin)) {
    return true;
  }

  // Vercelのプレビューデプロイメント用（*.vercel.app）
  if (origin.endsWith('.vercel.app') && process.env.VERCEL) {
    return true;
  }

  return false;
}

/**
 * CORSヘッダーを設定
 */
export function setCORSHeaders(
  response: NextResponse,
  requestOrigin: string | null
): NextResponse {
  const allowedOrigins = getAllowedOrigins();

  // オリジンが許可されている場合のみCORSヘッダーを設定
  if (requestOrigin && isOriginAllowed(requestOrigin)) {
    response.headers.set('Access-Control-Allow-Origin', requestOrigin);
  } else if (allowedOrigins.length > 0) {
    // フォールバック: 最初の許可オリジンを使用
    response.headers.set('Access-Control-Allow-Origin', allowedOrigins[0]);
  }

  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  response.headers.set('Access-Control-Max-Age', '86400'); // 24時間キャッシュ

  return response;
}

/**
 * セキュリティヘッダーを設定
 */
export function setSecurityHeaders(response: NextResponse): NextResponse {
  // XSS保護
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '1; mode=block');

  // Content Security Policy（必要に応じて調整）
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.openai.com"
  );

  // Referrer Policy
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');

  // Permissions Policy（不要な機能を無効化）
  response.headers.set(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=(), payment=()'
  );

  return response;
}

/**
 * APIレスポンスを作成（CORS + セキュリティヘッダー付き）
 */
export function createSecureResponse(
  data: Record<string, unknown>,
  status: number = 200,
  requestOrigin: string | null = null
): NextResponse {
  const response = NextResponse.json(data, { status });

  setCORSHeaders(response, requestOrigin);
  setSecurityHeaders(response);

  return response;
}

/**
 * OPTIONSリクエスト用のレスポンスを作成
 */
export function createOptionsResponse(requestOrigin: string | null = null): NextResponse {
  const response = NextResponse.json({}, { status: 200 });

  setCORSHeaders(response, requestOrigin);

  return response;
}
