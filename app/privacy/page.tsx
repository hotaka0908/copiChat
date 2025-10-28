import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'プライバシーポリシー | CopiChat',
  description: 'CopiChatにおける個人情報の取り扱いについてご説明します。',
}

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 py-12 px-4">
      <div className="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl p-8 md:p-12">
        <h1 className="text-3xl md:text-4xl font-bold text-gray-900 mb-8">プライバシーポリシー</h1>

        <div className="prose prose-slate max-w-none">
          <p className="text-sm text-gray-600 mb-8">最終更新日: 2025年10月28日</p>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">1. はじめに</h2>
            <p className="text-gray-700 mb-4">
              CopiChat（以下「当サービス」といいます）は、ユーザーの皆様のプライバシーを尊重し、個人情報の保護に努めています。本プライバシーポリシーは、当サービスにおける個人情報の取り扱いについて説明するものです。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">2. 収集する情報</h2>
            <p className="text-gray-700 mb-4">当サービスは、以下の情報を収集する場合があります。</p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3 mt-6">2.1 ユーザーが提供する情報</h3>
            <ul className="list-disc pl-6 text-gray-700 space-y-2">
              <li>プロフィール情報（名前、プロフィール画像など）</li>
              <li>お問い合わせ時に提供される情報（メールアドレス、お問い合わせ内容など）</li>
              <li>チャット履歴（AIとの対話内容）</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3 mt-6">2.2 自動的に収集される情報</h3>
            <ul className="list-disc pl-6 text-gray-700 space-y-2">
              <li>デバイス情報（OSバージョン、デバイスモデルなど）</li>
              <li>利用状況に関する情報（アクセス日時、利用機能など）</li>
              <li>IPアドレス</li>
              <li>クッキーおよび類似の技術を通じて収集される情報</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">3. 情報の利用目的</h2>
            <p className="text-gray-700 mb-4">収集した情報は、以下の目的で利用されます。</p>
            <ul className="list-disc pl-6 text-gray-700 space-y-2">
              <li>当サービスの提供、運営、改善</li>
              <li>ユーザーサポートおよびお問い合わせへの対応</li>
              <li>利用状況の分析とサービス品質の向上</li>
              <li>新機能や更新情報のお知らせ</li>
              <li>不正利用の防止およびセキュリティの維持</li>
              <li>法令に基づく義務の履行</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">4. 第三者サービスの利用</h2>
            <p className="text-gray-700 mb-4">
              当サービスは、以下の第三者サービスを利用しています。これらのサービスには、独自のプライバシーポリシーが適用されます。
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3 mt-6">4.1 OpenAI API</h3>
            <p className="text-gray-700 mb-4">
              当サービスは、AIチャット機能の提供にOpenAI APIを使用しています。ユーザーとの対話内容は、AI応答生成のためにOpenAIに送信されます。OpenAIのデータ使用ポリシーについては、
              <a href="https://openai.com/policies/privacy-policy" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">OpenAIのプライバシーポリシー</a>
              をご確認ください。
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3 mt-6">4.2 ホスティングサービス</h3>
            <p className="text-gray-700 mb-4">
              当サービスは、Vercelでホスティングされています。Vercelのプライバシーポリシーについては、
              <a href="https://vercel.com/legal/privacy-policy" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">Vercelのプライバシーポリシー</a>
              をご確認ください。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">5. データの保存と保護</h2>
            <p className="text-gray-700 mb-4">
              当サービスは、収集した情報を適切に管理し、不正アクセス、紛失、破壊、改ざん、漏洩等のリスクから保護するため、合理的な安全対策を実施しています。
            </p>
            <p className="text-gray-700">
              ただし、インターネットを通じた情報伝送やデータストレージの完全なセキュリティを保証することはできません。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">6. データの保存期間</h2>
            <p className="text-gray-700">
              当サービスは、収集した情報を、利用目的の達成に必要な期間、または法令で定められた期間保存します。保存期間経過後、または保存の必要がなくなった場合には、適切に削除または匿名化します。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">7. ユーザーの権利</h2>
            <p className="text-gray-700 mb-4">ユーザーは、自身の個人情報について、以下の権利を有します。</p>
            <ul className="list-disc pl-6 text-gray-700 space-y-2">
              <li>個人情報の開示請求</li>
              <li>個人情報の訂正、追加、削除の請求</li>
              <li>個人情報の利用停止または消去の請求</li>
              <li>プロフィール情報の編集（アプリ内設定画面より可能）</li>
            </ul>
            <p className="text-gray-700 mt-4">
              これらの権利を行使する場合は、<a href="mailto:ho@universalpine.com" className="text-blue-600 hover:underline">ho@universalpine.com</a> までご連絡ください。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">8. クッキー（Cookie）について</h2>
            <p className="text-gray-700 mb-4">
              当サービスは、サービスの利便性向上のためにクッキーを使用する場合があります。クッキーは、ユーザーのブラウザに保存される小さなテキストファイルです。
            </p>
            <p className="text-gray-700">
              ユーザーは、ブラウザの設定によりクッキーの使用を拒否することができます。ただし、クッキーを無効にした場合、当サービスの一部機能が正常に動作しない可能性があります。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">9. 子どもの個人情報</h2>
            <p className="text-gray-700">
              当サービスは、13歳未満の子どもから意図的に個人情報を収集することはありません。保護者の方が、お子様が個人情報を提供したことに気づかれた場合は、<a href="mailto:ho@universalpine.com" className="text-blue-600 hover:underline">ho@universalpine.com</a> まで速やかにご連絡ください。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">10. プライバシーポリシーの変更</h2>
            <p className="text-gray-700 mb-4">
              当サービスは、必要に応じて本プライバシーポリシーを変更することがあります。変更後のプライバシーポリシーは、当サービス上に掲載した時点から効力を生じます。
            </p>
            <p className="text-gray-700">
              重要な変更がある場合は、当サービス上で目立つ形で通知するよう努めます。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">11. お問い合わせ</h2>
            <p className="text-gray-700 mb-4">
              本プライバシーポリシーに関するご質問やご意見がある場合は、以下のメールアドレスまでご連絡ください。
            </p>
            <p className="text-gray-700">
              メールアドレス: <a href="mailto:ho@universalpine.com" className="text-blue-600 hover:underline">ho@universalpine.com</a>
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">12. 準拠法と管轄</h2>
            <p className="text-gray-700 mb-4">
              本プライバシーポリシーの解釈および適用は、日本法に準拠します。
            </p>
            <p className="text-gray-700">
              本プライバシーポリシーに関する紛争については、東京地方裁判所を第一審の専属的合意管轄裁判所とします。
            </p>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200">
          <Link
            href="/"
            className="inline-flex items-center text-blue-600 hover:text-blue-700 font-medium"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            ホームに戻る
          </Link>
        </div>
      </div>
    </div>
  )
}
