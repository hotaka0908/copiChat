import { NextRequest } from 'next/server';
import { createSecureResponse, createOptionsResponse } from '@/lib/security';

export async function GET(request: NextRequest) {
  const origin = request.headers.get('origin');

  try {
    return createSecureResponse(
      {
        status: 'success',
        message: 'API is working',
        environment: process.env.NODE_ENV,
        timestamp: new Date().toISOString()
      },
      200,
      origin
    );
  } catch (error) {
    console.error('Test API Error:', error);
    return createSecureResponse(
      {
        status: 'error',
        message: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      },
      500,
      origin
    );
  }
}

export async function POST(request: NextRequest) {
  const origin = request.headers.get('origin');

  try {
    const body = await request.json();

    return createSecureResponse(
      {
        status: 'success',
        received: body,
        timestamp: new Date().toISOString()
      },
      200,
      origin
    );
  } catch (error) {
    console.error('Test POST Error:', error);
    return createSecureResponse(
      {
        status: 'error',
        message: error instanceof Error ? error.message : 'Unknown error'
      },
      500,
      origin
    );
  }
}

export async function OPTIONS(request: NextRequest) {
  const origin = request.headers.get('origin');
  return createOptionsResponse(origin);
}