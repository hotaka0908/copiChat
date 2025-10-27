import { NextRequest } from 'next/server';
import { getPersonaById } from '@/lib/personas';
import { sendMessage, validateMessage } from '@/lib/ai';
import { createSecureResponse, createOptionsResponse } from '@/lib/security';

export async function POST(request: NextRequest) {
  const origin = request.headers.get('origin');

  try {
    const body = await request.text();
    const { personaId, messages, persona: clientPersona } = JSON.parse(body);

    // 入力検証
    if (!personaId || !messages || !Array.isArray(messages)) {
      return createSecureResponse(
        { error: 'Invalid request data' },
        400,
        origin
      );
    }

    // 人物データの取得（クライアントから送られた場合はそれを使用、なければサーバー側から取得）
    let persona = clientPersona;

    if (!persona) {
      // サーバー側のpersonas.tsから取得（既定の人物の場合）
      persona = getPersonaById(personaId);
    }

    if (!persona) {
      console.error(`Persona not found: ${personaId}`);
      return createSecureResponse(
        { error: 'Persona not found' },
        404,
        origin
      );
    }

    console.log(`💬 Chat with: ${persona.name} (${personaId})`)

    // メッセージの検証
    const lastMessage = messages[messages.length - 1];
    if (!lastMessage || lastMessage.role !== 'user' || !validateMessage(lastMessage.content)) {
      return createSecureResponse(
        { error: 'Invalid message format' },
        400,
        origin
      );
    }

    // OpenAI APIキーの確認
    if (!process.env.OPENAI_API_KEY) {
      return createSecureResponse(
        { error: 'OpenAI API key not configured' },
        500,
        origin
      );
    }

    // AI応答の生成
    const aiResponse = await sendMessage(persona, messages);

    return createSecureResponse(
      {
        message: aiResponse,
        persona: {
          id: persona.id,
          name: persona.name,
          era: persona.era
        }
      },
      200,
      origin
    );

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

    return createSecureResponse(
      {
        error: errorMessage,
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      500,
      origin
    );
  }
}

// OPTIONS メソッドのサポート（CORS対応）
export async function OPTIONS(request: NextRequest) {
  const origin = request.headers.get('origin');
  return createOptionsResponse(origin);
}