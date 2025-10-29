'use client';

import { motion } from 'framer-motion';
import { MessageCircle, ArrowRight, Gamepad2 } from 'lucide-react';
import Link from 'next/link';
import { getAllPersonas } from '@/lib/personas';

// 各人物に対応する肖像画像URL
const getAvatarUrl = (personaId: string): string => {
  const avatarMap: Record<string, string> = {
    'steve-jobs': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Steve_Jobs_Headshot_2010-CROP_%28cropped_2%29.jpg/256px-Steve_Jobs_Headshot_2010-CROP_%28cropped_2%29.jpg',
    'aristotle': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Aristotle_Altemps_Inv8575.jpg/256px-Aristotle_Altemps_Inv8575.jpg',
    'leonardo-da-vinci': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Francesco_Melzi_-_Portrait_of_Leonardo.png/256px-Francesco_Melzi_-_Portrait_of_Leonardo.png',
    'albert-einstein': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Einstein_1921_by_F_Schmutzer_-_restoration.jpg/256px-Einstein_1921_by_F_Schmutzer_-_restoration.jpg',
    'hotaka-funabashi': '/images/hotaka1996.png',
    'avicii': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Avicii_Veld_Music_Festival_Toronto_2011.jpg/256px-Avicii_Veld_Music_Festival_Toronto_2011.jpg',
    'mother-teresa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Mother_Teresa_1.jpg/256px-Mother_Teresa_1.jpg',
    'john-lennon': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/John_Lennon_1969_%28cropped%29.jpg/256px-John_Lennon_1969_%28cropped%29.jpg',
    'shigeo-nagashima': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Shigeo_Nagashima_1959.jpg/256px-Shigeo_Nagashima_1959.jpg',
    'alan-turing': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Alan_Turing_Aged_16.jpg/256px-Alan_Turing_Aged_16.jpg',
    'jesus-christ': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Christus_Ravenna_Mosaic.jpg/256px-Christus_Ravenna_Mosaic.jpg',
    'buddha': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/SeatedBuddha.jpg/256px-SeatedBuddha.jpg',
    'walt-disney': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Walt_Disney_1946.JPG/256px-Walt_Disney_1946.JPG',
  };
  return avatarMap[personaId] || '';
};

export default function HomePage() {
  const personas = getAllPersonas();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* ヘッダー */}
      <header className="bg-white border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-6 py-8">
          <div className="text-center">
            <motion.h1 
              className="text-5xl font-light text-gray-900 mb-3"
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              CopiChat
            </motion.h1>
            <motion.p
              className="text-lg text-gray-600 font-light mb-6"
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              歴史上の偉人と会話するAIチャットボット
            </motion.p>
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.3 }}
            >
              <Link href="/explore">
                <button className="bg-orange-600 hover:bg-orange-700 text-white px-6 py-3 rounded-lg font-medium transition-all duration-300 inline-flex items-center gap-2 shadow-lg hover:shadow-xl">
                  <Gamepad2 size={20} />
                  3D探索モードで体験
                </button>
              </Link>
            </motion.div>
          </div>
        </div>
      </header>

      {/* メインコンテンツ */}
      <main className="max-w-6xl mx-auto px-6 py-12">
        
        {/* セクションヘッダー */}
        <motion.div
          className="text-center mb-8"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.5 }}
        >
          <h2 className="text-2xl font-light text-gray-800 mb-2">人物を選んで対話を開始</h2>
          <p className="text-sm text-gray-600">クリックして各人物と直接チャットするか、3D探索モードで探してみましょう</p>
        </motion.div>

        {/* 人物選択グリッド */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {personas.map((persona, index) => (
            <motion.div
              key={persona.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 * index }}
            >
              <Link href={`/chat/${persona.id}`}>
                <div className="group bg-white border border-gray-200 rounded-lg hover:border-gray-300 hover:shadow-lg transition-all duration-300 cursor-pointer">
                  
                  {/* カードヘッダー */}
                  <div className="p-6 border-b border-gray-100">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="w-16 h-16 rounded-full overflow-hidden border-2 border-gray-200 shadow-sm">
                          <img 
                            src={getAvatarUrl(persona.id)}
                            alt={persona.name}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              const target = e.target as HTMLImageElement;
                              target.style.display = 'none';
                              const fallback = target.nextElementSibling as HTMLElement;
                              if (fallback) fallback.classList.remove('hidden');
                            }}
                          />
                          <div className="hidden w-full h-full bg-gray-100 flex items-center justify-center">
                            <span className="text-lg font-semibold text-gray-700">
                              {persona.nameEn.charAt(0)}
                            </span>
                          </div>
                        </div>
                        <div>
                          <h3 className="text-xl font-semibold text-gray-900">
                            {persona.name}
                          </h3>
                          <p className="text-sm text-gray-500">
                            {persona.era}
                          </p>
                        </div>
                      </div>
                      <ArrowRight 
                        size={20} 
                        className="text-gray-400 group-hover:text-gray-600 group-hover:translate-x-1 transition-all duration-300" 
                      />
                    </div>
                  </div>

                  {/* カードコンテンツ */}
                  <div className="p-6">
                    <p className="text-gray-700 mb-4 leading-relaxed">
                      {persona.title}
                    </p>

                    {/* 専門分野 */}
                    <div className="mb-4">
                      <div className="flex flex-wrap gap-2">
                        {persona.specialties.slice(0, 3).map((specialty, idx) => (
                          <span 
                            key={idx}
                            className="px-3 py-1 bg-gray-100 text-gray-700 text-xs rounded-full font-medium"
                          >
                            {specialty}
                          </span>
                        ))}
                      </div>
                    </div>

                    {/* 特徴的な言葉 */}
                    <blockquote className="border-l-3 border-gray-200 pl-4 italic text-gray-600 text-sm">
                      &ldquo;{persona.traits.famousQuotes[0]}&rdquo;
                    </blockquote>
                  </div>
                </div>
              </Link>
            </motion.div>
          ))}
        </div>

        {/* SEO強化コンテンツ */}
        <motion.div 
          className="mt-16 bg-white rounded-lg border border-gray-100 p-8"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 0.6 }}
        >
          <h2 className="text-2xl font-semibold text-gray-900 mb-4 text-center">
            CopiChatについて
          </h2>
          <div className="text-sm text-gray-600 leading-relaxed">
            <h3 className="font-semibold text-gray-800 mb-2">CopiChatとは</h3>
            <p className="mb-4">
              CopiChat（コピチャット）は、OpenAI GPT-4を使用した革新的なAIチャットボットです。
              歴史上の偉人たちの思考パターンと人格を忠実に再現し、ユーザーが直接対話できる教育的体験を提供します。
            </p>
            <p>
              スティーブ・ジョブズのイノベーション哲学、アリストテレスの論理学、
              レオナルド・ダ・ヴィンチの創造性、アインシュタインの科学的思考、
              船橋穂天の現代起業家精神、Aviciiの音楽革新を学習できます。
            </p>
          </div>
        </motion.div>

        {/* フッター */}
        <motion.div
          className="text-center mt-16 py-8 border-t border-gray-200"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 0.8 }}
        >
          <p className="text-gray-500 text-sm mb-2">
            Powered by OpenAI GPT-4 • Historical persona recreation
          </p>
          <p className="text-gray-400 text-xs mb-4">
            These conversations are AI simulations for educational purposes
          </p>
          <div className="flex justify-center space-x-4 text-xs text-gray-400 mb-4">
            <span>CopiChat</span>
            <span>•</span>
            <span>コピチャット</span>
            <span>•</span>
            <span>AI チャットボット</span>
            <span>•</span>
            <span>偉人・アーティストとの対話</span>
          </div>
          <div className="flex justify-center space-x-4 text-xs">
            <Link href="/terms" className="text-gray-500 hover:text-gray-700 underline">
              利用規約
            </Link>
            <span className="text-gray-400">•</span>
            <Link href="/privacy" className="text-gray-500 hover:text-gray-700 underline">
              プライバシーポリシー
            </Link>
          </div>
        </motion.div>
      </main>
    </div>
  );
}