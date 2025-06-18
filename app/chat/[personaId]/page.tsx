'use client';

import { useState, useRef, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowLeft, Send, Loader2, User, Brain, Clock, Lightbulb } from 'lucide-react';
import { getPersonaById } from '@/lib/personas';
import { Message } from '@/lib/ai';

export default function ChatPage() {
  const { personaId } = useParams();
  const router = useRouter();
  const persona = getPersonaById(personaId as string);
  
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (persona) {
      // 初期メッセージを追加
      const initialMessage: Message = {
        role: 'assistant',
        content: `こんにちは！私は${persona.name}です。${persona.era}を生きた${persona.title}として、あなたとお話しできることを嬉しく思います。何についてお聞きになりたいですか？`,
        timestamp: new Date()
      };
      setMessages([initialMessage]);
    }
  }, [persona]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleSend = async () => {
    if (!input.trim() || loading || !persona) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          personaId: persona.id,
          messages: [...messages, userMessage]
        })
      });

      if (!response.ok) throw new Error('Failed to get response');
      
      const data = await response.json();
      
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: data.message,
        timestamp: new Date()
      }]);
    } catch (error) {
      console.error('Error:', error);
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: '申し訳ありません。エラーが発生しました。もう一度お試しください。',
        timestamp: new Date()
      }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  if (!persona) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-800 mb-4">人物が見つかりません</h1>
          <button 
            onClick={() => router.push('/')}
            className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
          >
            ホームに戻る
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col">
      {/* ヘッダー */}
      <header className={`bg-gradient-to-r ${persona.backgroundGradient} ${persona.textColor} shadow-lg`}>
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => router.push('/')}
                className="p-2 rounded-full hover:bg-white/20 transition-colors"
              >
                <ArrowLeft size={24} />
              </button>
              
              <div className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm">
                  <span className="text-lg font-bold">
                    {persona.nameEn.charAt(0)}
                  </span>
                </div>
                <div>
                  <h1 className="text-xl font-bold">
                    {persona.name}
                  </h1>
                  <p className="text-sm opacity-90">
                    {persona.title} • {persona.era}
                  </p>
                </div>
              </div>
            </div>

            <div className="hidden md:flex items-center space-x-4 text-sm opacity-90">
              <div className="flex items-center">
                <Brain size={16} className="mr-1" />
                <span>AI人格再現</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* メッセージエリア */}
      <div className="flex-1 overflow-y-auto bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="space-y-6">
            <AnimatePresence>
              {messages.map((message, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                  className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div className={`max-w-3xl ${message.role === 'user' ? 'order-2' : 'order-1'}`}>
                    <div className="flex items-start space-x-3">
                      {message.role === 'assistant' && (
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-gradient-to-r ${persona.backgroundGradient} ${persona.textColor} flex-shrink-0`}>
                          <span className="font-bold text-sm">
                            {persona.nameEn.charAt(0)}
                          </span>
                        </div>
                      )}
                      
                      <div className={`flex-1 ${message.role === 'user' ? 'text-right' : 'text-left'}`}>
                        <div className={`inline-block px-4 py-3 rounded-2xl max-w-full ${
                          message.role === 'user' 
                            ? 'bg-blue-500 text-white' 
                            : 'bg-white shadow-md text-gray-800'
                        }`}>
                          <p className="whitespace-pre-wrap leading-relaxed">
                            {message.content}
                          </p>
                        </div>
                        <div className="flex items-center mt-2 text-xs text-gray-500">
                          {message.role === 'user' && (
                            <div className="flex items-center mr-2">
                              <User size={12} className="mr-1" />
                              <span>あなた</span>
                            </div>
                          )}
                          {message.role === 'assistant' && (
                            <div className="flex items-center mr-2">
                              <span>{persona.name}</span>
                            </div>
                          )}
                          <Clock size={12} className="mr-1" />
                          <span>
                            {message.timestamp?.toLocaleTimeString('ja-JP', { 
                              hour: '2-digit', 
                              minute: '2-digit' 
                            })}
                          </span>
                        </div>
                      </div>

                      {message.role === 'user' && (
                        <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white flex-shrink-0">
                          <User size={20} />
                        </div>
                      )}
                    </div>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>

            {loading && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="flex justify-start"
              >
                <div className="flex items-start space-x-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-gradient-to-r ${persona.backgroundGradient} ${persona.textColor}`}>
                    <span className="font-bold text-sm">
                      {persona.nameEn.charAt(0)}
                    </span>
                  </div>
                  <div className="bg-white shadow-md rounded-2xl px-4 py-3">
                    <div className="flex items-center space-x-2">
                      <Loader2 className="animate-spin" size={16} />
                      <span className="text-gray-600">考えています...</span>
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </div>
          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* 入力エリア */}
      <div className="bg-white border-t border-gray-200 p-4">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-end space-x-4">
            <div className="flex-1">
              <div className="relative">
                <textarea
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyPress={handleKeyPress}
                  placeholder={`${persona.name}に質問してください...`}
                  className="w-full resize-none border border-gray-300 rounded-2xl px-4 py-3 pr-12 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent max-h-32 min-h-[52px]"
                  rows={1}
                  disabled={loading}
                />
                <button
                  onClick={handleSend}
                  disabled={!input.trim() || loading}
                  className="absolute right-2 bottom-2 p-2 bg-blue-500 text-white rounded-full hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  <Send size={16} />
                </button>
              </div>
            </div>
          </div>
          
          <div className="mt-3 text-center">
            <p className="text-xs text-gray-500 flex items-center justify-center">
              <Lightbulb size={12} className="mr-1" />
              {persona.name}の専門分野: {persona.specialties.slice(0, 3).join(', ')}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}