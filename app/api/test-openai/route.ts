import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export async function GET() {
  try {
    console.log('Testing OpenAI API connection...');
    
    if (!process.env.OPENAI_API_KEY) {
      throw new Error('OPENAI_API_KEY not found in environment variables');
    }

    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    console.log('Making test request to OpenAI...');
    
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
    console.log('OpenAI API test successful:', response);

    return NextResponse.json({
      status: 'success',
      message: 'OpenAI API connection working',
      testResponse: response,
      model: 'gpt-4o-mini',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('OpenAI API Test Error:', error);
    
    let errorMessage = 'Unknown error';
    let errorCode = 'UNKNOWN';
    
    if (error instanceof Error) {
      errorMessage = error.message;
      
      if (error.message.includes('API key')) {
        errorCode = 'INVALID_API_KEY';
      } else if (error.message.includes('rate limit')) {
        errorCode = 'RATE_LIMIT';
      } else if (error.message.includes('model')) {
        errorCode = 'MODEL_ERROR';
      } else if (error.message.includes('network') || error.message.includes('fetch')) {
        errorCode = 'NETWORK_ERROR';
      }
    }

    return NextResponse.json(
      {
        status: 'error',
        message: errorMessage,
        errorCode,
        hasApiKey: !!process.env.OPENAI_API_KEY,
        apiKeyLength: process.env.OPENAI_API_KEY?.length || 0,
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}