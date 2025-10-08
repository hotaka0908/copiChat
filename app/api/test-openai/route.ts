import { NextRequest } from 'next/server';
import OpenAI from 'openai';
import { createSecureResponse, createOptionsResponse } from '@/lib/security';

export async function GET(request: NextRequest) {
  const origin = request.headers.get('origin');

  try {
    if (!process.env.OPENAI_API_KEY) {
      return createSecureResponse(
        {
          status: 'error',
          message: 'OPENAI_API_KEY not configured',
        },
        500,
        origin
      );
    }

    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "You are a helpful assistant. Respond with a simple greeting in Japanese."
        },
        {
          role: "user",
          content: "Hello"
        }
      ],
      max_tokens: 50,
      temperature: 0.7
    });

    const response = completion.choices[0]?.message?.content || 'No response';

    return createSecureResponse(
      {
        status: 'success',
        message: 'OpenAI API connection working',
        testResponse: response,
        model: 'gpt-4o-mini',
        timestamp: new Date().toISOString()
      },
      200,
      origin
    );

  } catch (error) {
    console.error('OpenAI API Test Error:', error);

    let errorMessage = 'API test failed';
    let errorCode = 'UNKNOWN';

    if (error instanceof Error) {
      if (error.message.includes('API key')) {
        errorMessage = 'Invalid API key';
        errorCode = 'INVALID_API_KEY';
      } else if (error.message.includes('rate limit')) {
        errorMessage = 'Rate limit exceeded';
        errorCode = 'RATE_LIMIT';
      } else if (error.message.includes('model')) {
        errorMessage = 'Model error';
        errorCode = 'MODEL_ERROR';
      } else if (error.message.includes('network') || error.message.includes('fetch')) {
        errorMessage = 'Network error';
        errorCode = 'NETWORK_ERROR';
      }
    }

    return createSecureResponse(
      {
        status: 'error',
        message: errorMessage,
        errorCode,
        timestamp: new Date().toISOString()
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