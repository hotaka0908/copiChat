import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: '利用規約 | DTalk',
  description: 'DTalkサービスの利用規約をご確認ください。',
}

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 py-12 px-4">
      <div className="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl p-8 md:p-12">
        <h1 className="text-3xl md:text-4xl font-bold text-gray-900 mb-8">利用規約</h1>

        <div className="prose prose-slate max-w-none">
          <p className="text-sm text-gray-600 mb-8">最終更新日: 2025年10月28日</p>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第1条（適用）</h2>
            <p className="text-gray-700 mb-4">
              本規約は、DTalk（以下「当サービス」といいます）の利用に関する条件を、当サービスを利用するすべてのユーザー（以下「ユーザー」といいます）と当サービス提供者（以下「当社」といいます）との間で定めるものです。
            </p>
            <p className="text-gray-700">
              ユーザーは、当サービスを利用することにより、本規約に同意したものとみなされます。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第2条（サービスの内容）</h2>
            <p className="text-gray-700 mb-4">
              当サービスは、AI技術を活用し、歴史上の人物や著名人のペルソナとの対話を通じて、教育的体験を提供するチャットボットサービスです。
            </p>
            <p className="text-gray-700">
              当サービスで提供される対話内容は、AIによって生成されたものであり、実在の人物の実際の発言や意見ではありません。教育・娯楽目的でのみご利用ください。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第3条（利用条件）</h2>
            <p className="text-gray-700 mb-4">ユーザーは、当サービスの利用にあたり、以下の行為を行ってはならないものとします。</p>
            <ul className="list-disc pl-6 text-gray-700 space-y-2">
              <li>法令または公序良俗に違反する行為</li>
              <li>犯罪行為に関連する行為</li>
              <li>当社または第三者の知的財産権、肖像権、プライバシー、名誉その他の権利または利益を侵害する行為</li>
              <li>当サービスのネットワークまたはシステム等に過度な負荷をかける行為</li>
              <li>当サービスの運営を妨害するおそれのある行為</li>
              <li>不正アクセスをし、またはこれを試みる行為</li>
              <li>他のユーザーに関する個人情報等を収集または蓄積する行為</li>
              <li>他のユーザーに成りすます行為</li>
              <li>反社会的勢力に対して直接または間接に利益を供与する行為</li>
              <li>その他、当社が不適切と判断する行為</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第4条（免責事項）</h2>
            <p className="text-gray-700 mb-4">
              当社は、当サービスの内容、品質、正確性、完全性、有用性、安全性について、いかなる保証も行いません。
            </p>
            <p className="text-gray-700 mb-4">
              当サービスで提供される情報は、AIによって生成されたものであり、その正確性や信頼性について当社は一切の責任を負いません。重要な判断や決定を行う際は、必ず他の信頼できる情報源を参照してください。
            </p>
            <p className="text-gray-700">
              当サービスの利用によってユーザーに生じた損害について、当社は一切の責任を負いません。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第5条（知的財産権）</h2>
            <p className="text-gray-700 mb-4">
              当サービスに関する知的財産権は、すべて当社または当社にライセンスを許諾している第三者に帰属します。
            </p>
            <p className="text-gray-700">
              本規約に基づく当サービスの利用許諾は、当サービスに関する知的財産権の使用許諾を意味するものではありません。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第6条（サービスの変更・停止）</h2>
            <p className="text-gray-700 mb-4">
              当社は、ユーザーへの事前の通知なく、当サービスの内容を変更し、または提供を停止することができるものとします。
            </p>
            <p className="text-gray-700">
              当社は、当サービスの変更または停止によってユーザーに生じた損害について、一切の責任を負いません。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第7条（利用規約の変更）</h2>
            <p className="text-gray-700">
              当社は、必要と判断した場合には、ユーザーに通知することなく本規約を変更することができるものとします。変更後の利用規約は、当サービス上に掲載した時点から効力を生じるものとします。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第8条（準拠法・裁判管轄）</h2>
            <p className="text-gray-700 mb-4">
              本規約の解釈にあたっては、日本法を準拠法とします。
            </p>
            <p className="text-gray-700">
              当サービスに関して紛争が生じた場合には、東京地方裁判所を第一審の専属的合意管轄裁判所とします。
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">第9条（お問い合わせ）</h2>
            <p className="text-gray-700 mb-4">
              本規約に関するお問い合わせは、以下のメールアドレスまでご連絡ください。
            </p>
            <p className="text-gray-700">
              メールアドレス: <a href="mailto:ho@universalpine.com" className="text-blue-600 hover:underline">ho@universalpine.com</a>
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
