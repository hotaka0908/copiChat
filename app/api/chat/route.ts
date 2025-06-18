import { NextRequest, NextResponse } from 'next/server';
import { getPersonaById } from '@/lib/personas';
import { sendMessage, Message, validateMessage } from '@/lib/ai';

export async function POST(request: NextRequest) {
  try {
    console.log('API Chat endpoint called');
    
    const { personaId, messages } = await request.json();
    console.log('Received data:', { personaId, messageCount: messages?.length });

    // 入力検証
    if (!personaId || !messages || !Array.isArray(messages)) {
      console.log('Invalid request data');
      return NextResponse.json(
        { error: 'Invalid request data' },
        { status: 400 }
      );
    }

    // 人物データの取得
    const persona = getPersonaById(personaId);
    if (!persona) {
      console.log('Persona not found:', personaId);
      return NextResponse.json(
        { error: 'Persona not found' },
        { status: 404 }
      );
    }

    // メッセージの検証
    const lastMessage = messages[messages.length - 1];
    if (!lastMessage || lastMessage.role !== 'user' || !validateMessage(lastMessage.content)) {
      console.log('Invalid message format');
      return NextResponse.json(
        { error: 'Invalid message format' },
        { status: 400 }
      );
    }

    // OpenAI APIキーの確認
    if (!process.env.OPENAI_API_KEY) {
      console.log('OpenAI API key not configured');
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      );
    }

    console.log('Calling OpenAI API...');
    // AI応答の生成
    const aiResponse = await sendMessage(persona, messages);
    console.log('OpenAI response received');

    return NextResponse.json({
      message: aiResponse,
      persona: {
        id: persona.id,
        name: persona.name,
        era: persona.era
      }
    });

  } catch (error) {
    console.error('Chat API Error:', error);
    
    // エラーメッセージの詳細化
    let errorMessage = 'Internal server error';
    if (error instanceof Error) {
      if (error.message.includes('API key')) {
        errorMessage = 'AI service configuration error';
      } else if (error.message.includes('rate limit')) {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (error.message.includes('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }
    }

    return NextResponse.json(
      { error: errorMessage },
      { status: 500 }
    );
  }
}

// OPTIONS メソッドのサポート（CORS対応）
export async function OPTIONS() {
  return NextResponse.json({}, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}