import OpenAI from 'openai';
import { Persona } from './personas';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY!,
});

export interface Message {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp?: Date;
}

export async function sendMessage(
  persona: Persona,
  messages: Message[]
): Promise<string> {
  try {
    console.log('Starting OpenAI API call for persona:', persona.name);
    console.log('API Key present:', !!process.env.OPENAI_API_KEY);
    
    const systemMessage: Message = {
      role: 'system',
      content: `${persona.systemPrompt}
      
重要な指示：
- あなたは${persona.name}（${persona.nameEn}、${persona.era}）として完全に役割を演じてください
- 特徴的なフレーズ: ${persona.traits.keyPhrases.join(', ')}
- 決断の仕方: ${persona.traits.decisionMaking}
- 専門分野: ${persona.specialties.join(', ')}
- 現代の話題にも、${persona.name}の視点と価値観から答えてください
- 日本語で自然に回答し、必要に応じて当時の時代背景も考慮してください
- ${persona.name}らしい話し方と思考パターンを完全に再現してください`
    };

    console.log('Calling OpenAI with messages count:', messages.length + 1);

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [systemMessage, ...messages.map(msg => ({
        role: msg.role,
        content: msg.content
      }))],
      temperature: 0.8,
      max_tokens: 1000,
      presence_penalty: 0.1,
      frequency_penalty: 0.1
    });

    console.log('OpenAI API call successful');
    return completion.choices[0]?.message?.content || '申し訳ありませんが、応答を生成できませんでした。';
  } catch (error) {
    console.error('OpenAI API Error details:', error);
    
    let errorMessage = 'AI応答の生成中にエラーが発生しました';
    
    if (error instanceof Error) {
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);
      
      // OpenAI特有のエラーを詳細に分析
      if (error.message.includes('API key')) {
        errorMessage = 'OpenAI APIキーが無効です';
      } else if (error.message.includes('rate limit') || error.message.includes('429')) {
        errorMessage = 'API使用量の上限に達しました。しばらく待ってからお試しください';
      } else if (error.message.includes('model') || error.message.includes('engine')) {
        errorMessage = 'AIモデルの設定に問題があります';
      } else if (error.message.includes('timeout')) {
        errorMessage = 'AIサービスの応答がタイムアウトしました';
      } else if (error.message.includes('network') || error.message.includes('fetch')) {
        errorMessage = 'ネットワーク接続に問題があります';
      } else if (error.message.includes('400')) {
        errorMessage = 'リクエストの形式に問題があります';
      } else if (error.message.includes('401') || error.message.includes('403')) {
        errorMessage = 'API認証に失敗しました';
      } else if (error.message.includes('500') || error.message.includes('502') || error.message.includes('503')) {
        errorMessage = 'AIサービスに一時的な問題が発生しています';
      }
    }
    
    throw new Error(errorMessage);
  }
}

export function formatMessageHistory(messages: Message[]): string {
  return messages
    .filter(msg => msg.role !== 'system')
    .map(msg => `${msg.role === 'user' ? 'ユーザー' : 'アシスタント'}: ${msg.content}`)
    .join('\n\n');
}

export function validateMessage(content: string): boolean {
  console.log('Validating message:', { content, length: content?.length });
  
  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    console.log('Message validation failed: empty or invalid content');
    return false;
  }
  if (content.length > 8000) {
    console.log('Message validation failed: too long');
    return false;
  }
  
  console.log('Message validation passed');
  return true;
}