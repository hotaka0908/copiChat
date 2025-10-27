import { NextRequest } from 'next/server';
import OpenAI from 'openai';
import { createSecureResponse, createOptionsResponse } from '@/lib/security';

// OpenAIクライアントを遅延初期化
let openai: OpenAI | null = null;

function getOpenAIClient(): OpenAI {
  if (!openai) {
    openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY || '',
    });
  }
  return openai;
}

// Wikipedia APIから人物情報を取得
async function fetchWikipediaInfo(name: string): Promise<{
  exists: boolean;
  summary?: string;
  imageUrl?: string;
  categories?: string[];
}> {
  try {
    console.log(`🔍 Searching Wikipedia for: ${name}`);

    // Wikipedia検索API（日本語版と英語版を両方試す）
    const searchUrl = `https://ja.wikipedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(name)}&format=json&origin=*`;
    const searchResponse = await fetch(searchUrl);
    const searchData = await searchResponse.json();

    if (!searchData.query || searchData.query.search.length === 0) {
      console.log(`❌ No Wikipedia page found for: ${name}`);
      return { exists: false };
    }

    const pageTitle = searchData.query.search[0].title;
    console.log(`✅ Found Wikipedia page: ${pageTitle}`);

    // ページの詳細情報を取得
    const pageUrl = `https://ja.wikipedia.org/w/api.php?action=query&titles=${encodeURIComponent(pageTitle)}&prop=extracts|pageimages|categories&exintro=true&explaintext=true&piprop=thumbnail&pithumbsize=256&format=json&origin=*`;
    const pageResponse = await fetch(pageUrl);
    const pageData = await pageResponse.json();

    const pages = pageData.query.pages;
    const pageId = Object.keys(pages)[0];
    const page = pages[pageId];

    // 画像URLの取得（Wikimedia Commons形式に変換）
    let imageUrl = '';
    if (page.thumbnail && page.thumbnail.source) {
      imageUrl = page.thumbnail.source;
      console.log(`📷 Found image: ${imageUrl}`);
    }

    // カテゴリ情報から人物の分野を推測
    const categories: string[] = [];
    if (page.categories) {
      categories.push(...page.categories.map((cat: any) => cat.title));
    }

    return {
      exists: true,
      summary: page.extract || '',
      imageUrl,
      categories
    };
  } catch (error) {
    console.error('Wikipedia API Error:', error);
    return { exists: false };
  }
}

// 参考例のPersona（ウォルト・ディズニー）
const EXAMPLE_PERSONA = {
  id: "walt-disney",
  name: "ウォルト・ディズニー",
  nameEn: "Walt Disney",
  era: "1901-1966",
  title: "アニメーター・映画プロデューサー・エンターテイナー",
  avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Walt_Disney_1946.JPG/256px-Walt_Disney_1946.JPG",
  systemPrompt: "あなたはウォルト・ディズニーです。創造力と夢を重んじ、常に新しい世界を切り開いてきたエンターテイナーです。人々に夢と希望を与えるために、物語を語り続け、テーマパークを創造しました。あなたは決して諦めず、困難に直面しても常に前進しました。自分の信念を貫き、チームを鼓舞し、世界中の人々に魔法のような体験を提供することに情熱を注いでください。",
  backgroundGradient: ["blue-500", "purple-600"],
  textColor: "white",
  traits: {
    speechPattern: ["Dream big", "Believe in magic", "Keep moving forward"],
    philosophy: ["夢を追いかける勇気を持て", "想像力に限界はない", "常に新しいものを創造する"],
    decisionMaking: "創造的かつ革新的なアプローチ",
    keyPhrases: ["If you can dream it, you can do it", "All our dreams can come true, if we have the courage to pursue them", "It's kind of fun to do the impossible"],
    famousQuotes: ["The way to get started is to quit talking and begin doing", "The more you like yourself, the less you are like anyone else, which makes you unique"]
  },
  specialties: ["アニメーション", "テーマパークデザイン", "映画製作", "ストーリーテリング"],
  historicalContext: "ウォルト・ディズニーは、アメリカのアニメーター、映画プロデューサー、声優であり、ディズニーランドやディズニーワールドなどのテーマパークを創設したことで知られています。彼はミッキーマウスをはじめとする数々のキャラクターを生み出し、アニメーション映画の先駆者として映画業界に多大な影響を与えました。ディズニーは、アニメーション映画を通じてストーリーテリングを革新し、人々に夢と希望を与え続けました。彼のビジョンは、今日もなお多くの人々に影響を与え続けています。",
  category: "business"
};

export async function POST(request: NextRequest) {
  const origin = request.headers.get('origin');

  try {
    const body = await request.text();
    const { name, existingPersonaNames } = JSON.parse(body);

    // 入力検証
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return createSecureResponse(
        { error: 'Invalid name parameter' },
        400,
        origin
      );
    }

    const trimmedName = name.trim();

    // 名前の長さチェック
    if (trimmedName.length < 2) {
      return createSecureResponse(
        { error: 'Name too short (minimum 2 characters)' },
        400,
        origin
      );
    }

    if (trimmedName.length > 100) {
      return createSecureResponse(
        { error: 'Name too long' },
        400,
        origin
      );
    }

    // 既存人物との重複チェック
    if (existingPersonaNames && Array.isArray(existingPersonaNames)) {
      const nameExists = existingPersonaNames.some(
        (existingName: string) => existingName.toLowerCase() === trimmedName.toLowerCase()
      );

      if (nameExists) {
        return createSecureResponse(
          { error: `「${trimmedName}」は既にBookshelfに追加されています` },
          400,
          origin
        );
      }
    }

    // Wikipedia APIで実在性と情報を確認
    console.log(`🔍 Step 1: Checking Wikipedia for ${trimmedName}...`);
    const wikiInfo = await fetchWikipediaInfo(trimmedName);

    if (!wikiInfo.exists) {
      return createSecureResponse(
        {
          error: `「${trimmedName}」に関する情報が見つかりませんでした。\n実在する有名人の名前を入力してください。`,
          suggestion: 'Wikipedia に記事がある人物名を入力してください'
        },
        404,
        origin
      );
    }

    console.log(`✅ Step 2: Wikipedia info found. Summary length: ${wikiInfo.summary?.length || 0}`);

    // OpenAI APIキーの確認
    if (!process.env.OPENAI_API_KEY) {
      return createSecureResponse(
        { error: 'OpenAI API key not configured' },
        500,
        origin
      );
    }

    // 参考例をJSON文字列化
    const exampleJSON = JSON.stringify(EXAMPLE_PERSONA, null, 2);

    // Wikipedia情報を整形
    const wikipediaContext = wikiInfo.summary ? `
【Wikipediaからの情報】
${wikiInfo.summary.substring(0, 1000)}
${wikiInfo.imageUrl ? `\n画像URL: ${wikiInfo.imageUrl}` : ''}
` : '';

    console.log(`📝 Step 3: Generating persona with OpenAI (gpt-4o)...`);

    // プロンプトの生成（Wikipedia情報を含む）
    const prompt = `あなたは歴史上の人物や著名人の詳細なプロフィールを生成する専門家です。
以下のJSON形式の完璧な例を参考に、「${trimmedName}」という人物の詳細情報を同じ品質レベルでJSON形式で生成してください。

${wikipediaContext}

【完璧な参考例】
${exampleJSON}

【厳密な要件】

1. **JSON構造**: 上記と全く同じJSON構造で出力してください

2. **基本情報**:
   - id: UUID形式で一意のIDを生成（例: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"）
   - name: 「${trimmedName}」を使用
   - nameEn: 英語名またはローマ字表記
   - era: 生没年や活動時期（例: "1901-1966", "BC384-BC322"）
   - title: 職業や肩書き（簡潔かつ具体的に）

3. **avatar画像URL**:
   ${wikiInfo.imageUrl ? `- **以下のWikipediaの画像URLを使用してください**: "${wikiInfo.imageUrl}"` : `- Wikipediaの256px版画像URLを使用
   - 形式: "https://upload.wikimedia.org/wikipedia/commons/thumb/[2文字]/[2文字]/[filename]/256px-[filename]"
   - 実在する人物の場合は必ず本物の画像URLを生成（Wikipedia Commonsから実在する画像を検索して正確なパスを使用）
   - 画像が見つからない場合は空文字 "" を使用`}

4. **systemPrompt** (最重要):
   - 300-500文字以上の詳細なプロンプトを作成
   - 人物の性格、話し方、思考パターンを具体的に描写
   - 「あなたは[人物名]です。」で始める
   - 人物の特徴、信念、行動様式を詳しく説明
   - 会話でどのように振る舞うべきかを明確に指示
   - 参考例と同じレベルの詳細度を維持

5. **backgroundGradient**:
   - 2-3色の配列（例: ["blue-500", "purple-600"]）
   - 人物のイメージに合った色を選択
   - 使用可能な色: red, orange, yellow, green, blue, indigo, purple, pink, gray（各色に-500, -600, -700, -800, -900のバリエーション）

6. **textColor**: 必ず "white" を使用

7. **traits（非常に重要）**:
   - speechPattern: 3-4個の特徴的な話し方や口癖
   - philosophy: 3-6個の人物の哲学や信念
   - decisionMaking: 意思決定の特徴を1文で説明
   - keyPhrases: 3-4個の特徴的なフレーズ
   - famousQuotes: 2-4個の実際の名言（日本語と英語の両方を含む）

8. **specialties**: 3-5個の専門分野や得意領域

9. **historicalContext**:
   - 200-400文字の詳細な歴史的背景
   - 生い立ち、主要な業績、影響、レガシーを含む
   - 具体的な年代や出来事を含める

10. **category**（重要）:
   - 人物の主な活動領域に基づいて、以下のいずれかのカテゴリを自動選択
   - 選択肢（英語の値を使用）:
     * "business": ビジネス・起業家（例: 経営者、実業家、企業家）
     * "philosophy": 哲学・宗教（例: 哲学者、宗教指導者、思想家）
     * "science": 科学・技術（例: 科学者、発明家、数学者、技術者）
     * "art": 芸術・文化（例: 画家、彫刻家、作家、建築家）
     * "music": 音楽・芸能（例: 音楽家、作曲家、歌手、DJ、パフォーマー）
     * "sports": スポーツ（例: アスリート、スポーツ選手）
     * "social": 社会活動・政治（例: 政治家、社会運動家、活動家）
   - 複数の領域で活躍した人物の場合は、最も影響力が大きかった主要領域を選択

【品質基準】
- すべての項目を参考例と同等以上の詳細度で記載
- 実在の人物の場合は正確な歴史的事実に基づく
- systemPromptは特に詳細に（300文字以上）
- famousQuotesは実際の名言を使用
- avatar URLは実在するWikipedia画像を使用

【出力形式】
- JSONのみを出力し、他の説明やマークダウンは一切含めない
- 文字エンコーディングはUTF-8
- すべての文字列は適切にエスケープ

上記の基準を厳密に守って、最高品質の人物プロフィールを生成してください。`;

    // OpenAI APIリクエスト
    const completion = await getOpenAIClient().chat.completions.create({
      model: "gpt-4o", // 高品質な人物生成のためgpt-4oを使用
      messages: [
        {
          role: "system",
          content: "You are a helpful assistant that generates persona data in JSON format."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.7,
      response_format: { type: "json_object" }
    });

    const content = completion.choices[0]?.message?.content;

    if (!content) {
      return createSecureResponse(
        { error: 'No content in OpenAI response' },
        500,
        origin
      );
    }

    // JSONパース
    let persona;
    try {
      persona = JSON.parse(content);
    } catch (error) {
      console.error('JSON parse error:', error);
      return createSecureResponse(
        { error: 'Invalid JSON from OpenAI' },
        500,
        origin
      );
    }

    // 基本的なバリデーション
    if (!persona.id || !persona.name || !persona.systemPrompt) {
      return createSecureResponse(
        { error: 'Invalid persona structure' },
        500,
        origin
      );
    }

    return createSecureResponse(
      { persona },
      200,
      origin
    );

  } catch (error) {
    console.error('Generate Persona API Error:', error);

    let errorMessage = 'Internal server error';
    if (error instanceof Error) {
      if (error.message.includes('API key')) {
        errorMessage = 'OpenAI API key configuration error';
      } else if (error.message.includes('rate limit') || error.message.includes('429')) {
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
