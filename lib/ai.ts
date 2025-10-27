import OpenAI from 'openai';
import { Persona } from './personas';

// OpenAIクライアントを遅延初期化（ビルド時のエラーを回避）
let openai: OpenAI | null = null;

function getOpenAIClient(): OpenAI {
  if (!openai) {
    openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY || '',
    });
  }
  return openai;
}

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
    // ユーザーの最後のメッセージの長さを取得
    const lastUserMessage = messages.filter(m => m.role === 'user').pop();
    const userMessageLength = lastUserMessage?.content.length || 100;

    // ユーザーのメッセージの長さに応じてmax_tokensを3段階で設定
    // 目標: 100字以内の簡潔な応答
    let maxTokens: number;
    if (userMessageLength < 30) {
      maxTokens = 100;  // 短い質問 → 約65字
    } else if (userMessageLength < 100) {
      maxTokens = 150;  // 普通の質問 → 約100字
    } else {
      maxTokens = 200;  // 長い質問 → 約130字
    }

    const systemMessage: Message = {
      role: 'system',
      content: `${persona.systemPrompt}

あなたは${persona.name}（${persona.nameEn}、${persona.era}）として会話してください。

【最優先ルール】
- **100字以内で答える**（長くても2-3文まで）
- 友達とのLINEのような気軽な会話
- 質問と同じくらいの分量で返す
- 必ず句点（。）で終わらせる

【話し方】
- ${persona.name}らしい話し方: ${persona.traits.keyPhrases.join(', ')}
- 決断の仕方: ${persona.traits.decisionMaking}
- 専門分野: ${persona.specialties.join(', ')}

【応答の型】
1. まず結論を一言で
2. 理由や説明を短く（1-2文）
3. 必要なら具体例を一つ

会話のキャッチボールを大切に。長すぎる説明より、簡潔で心に残る一言を。`
    };

    const completion = await getOpenAIClient().chat.completions.create({
      model: "gpt-4o-mini",
      messages: [systemMessage, ...messages.map(msg => ({
        role: msg.role,
        content: msg.content
      }))],
      temperature: 0.8,
      max_tokens: maxTokens,
      presence_penalty: 0.1,
      frequency_penalty: 0.1
    });

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
      } else if (error.message.includes('rate limit') || error.message.includes('429') || error.message.includes('quota')) {
        errorMessage = 'OpenAI APIの使用量制限に達しています。管理者にお問い合わせください。';
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
  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    return false;
  }
  if (content.length > 8000) {
    return false;
  }

  return true;
}