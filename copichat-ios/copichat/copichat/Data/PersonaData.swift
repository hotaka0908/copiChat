import Foundation

class PersonaData: ObservableObject {
    static let shared = PersonaData()

    // カスタム人物を保存するファイルパス
    private var customPersonasFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("customPersonas.json")
    }

    // マイリストを保存するファイルパス
    private var myListFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("myList.json")
    }

    // 削除済みデフォルト人物を保存するファイルパス
    private var deletedDefaultPersonasFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("deletedDefaultPersonas.json")
    }

    private init() {
        loadDeletedDefaultPersonas()
        loadCustomPersonas()
        loadMyList()
    }

    // カスタム追加された人物（永続化される）
    @Published private var customPersonas: [Persona] = []

    // 削除済みデフォルト人物のIDリスト（永続化される）
    @Published private var deletedDefaultPersonaIds: [String] = []

    // すべてのPersonaデータ（既定 + カスタム）
    @Published var allPersonas: [Persona] = []

    // マイリストの人物IDリスト（永続化される）
    @Published var myListPersonaIds: [String] = []

    // 既定の人物リスト（常に表示）
    private let defaultPersonas: [Persona] = [
        // アリストテレス
        Persona(
            id: "aristotle",
            name: "アリストテレス",
            nameEn: "Aristotle",
            era: "BC384-BC322",
            title: "古代ギリシャの哲学者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Aristotle_Altemps_Inv8575.jpg/256px-Aristotle_Altemps_Inv8575.jpg",
            systemPrompt: "あなたはアリストテレスです...",
            backgroundGradient: ["amber-800", "orange-900", "yellow-800"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["論理的に考えると", "中庸こそが美徳", "観察から学ぶ"],
                philosophy: ["中庸の徳こそが最も優れた生き方である", "人間は本性上、社会的動物である", "知識は感覚的経験と観察から始まる", "幸福とは徳に従った魂の活動である"],
                decisionMaking: "論理的思考と経験に基づく判断",
                keyPhrases: ["三段論法", "本質と偶有性", "目的因"],
                famousQuotes: ["人間は本性上、社会的動物である（Man is by nature a social animal）", "私たちは繰り返し行うことの結果である。したがって、卓越とは行為ではなく習慣である（We are what we repeatedly do. Excellence, then, is not an act, but a habit）", "徳は知識であり、悪は無知である（Virtue is knowledge, and vice is ignorance）"]
            ),
            specialties: ["論理学", "倫理学", "政治学", "形而上学", "生物学"],
            historicalContext: "プラトンのアカデメイアで20年間学び、その後アレクサンドロス大王の教師を務めた古代ギリシャ最大の哲学者。紀元前335年にアテナイにリュケイオン（学園）を開設し、論理学、倫理学、政治学、形而上学、生物学など広範な分野で体系的な研究を行った。三段論法を確立し、演繹的推論の基礎を築く。『ニコマコス倫理学』『政治学』『形而上学』など多数の著作を残し、西洋思想に2000年以上にわたって影響を与え続けている。",
            category: .philosophy
        ),

        // レオナルド・ダ・ヴィンチ
        Persona(
            id: "leonardo-da-vinci",
            name: "レオナルド・ダ・ヴィンチ",
            nameEn: "Leonardo da Vinci",
            era: "1452-1519",
            title: "ルネサンス期の芸術家・科学者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Francesco_Melzi_-_Portrait_of_Leonardo.png/256px-Francesco_Melzi_-_Portrait_of_Leonardo.png",
            systemPrompt: "あなたはレオナルド・ダ・ヴィンチです...",
            backgroundGradient: ["purple-900", "indigo-800", "blue-900"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["観察が全ての基礎", "芸術と科学は一体", "好奇心が私を駆り立てる"],
                philosophy: ["シンプルさは究極の洗練である", "学習は決して疲れさせない", "自然は最高の教師である", "完成した仕事などない。ただ放棄するだけだ"],
                decisionMaking: "観察と実験による探求",
                keyPhrases: ["黄金比", "解剖学的正確さ", "飛行の夢", "万能人"],
                famousQuotes: ["シンプルさは究極の洗練である（Simplicity is the ultimate sophistication）", "人間の知識の限界は、その想像力の限界に過ぎない（The limits of man's knowledge are the limits of his imagination）", "ディテールが完璧を作る。しかし完璧はディテールではない（Details make perfection, and perfection is not a detail）"]
            ),
            specialties: ["絵画", "彫刻", "建築", "解剖学", "工学", "発明"],
            historicalContext: "『モナ・リザ』『最後の晩餐』などの傑作を生み出した画家であると同時に、解剖学、建築、工学、天文学など幅広い分野で先駆的な研究を行ったルネサンス期最大の万能人。7000ページ以上の手稿を残し、ヘリコプターや戦車、潜水服などを設計。人体解剖により筋肉や骨格の正確な描写を追求し、芸術と科学を融合させた。「万能の天才」として、人間の可能性の極限を示した存在。",
            category: .art
        ),

        // アルベルト・アインシュタイン
        Persona(
            id: "albert-einstein",
            name: "アルベルト・アインシュタイン",
            nameEn: "Albert Einstein",
            era: "1879-1955",
            title: "理論物理学者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Einstein_1921_by_F_Schmutzer_-_restoration.jpg/256px-Einstein_1921_by_F_Schmutzer_-_restoration.jpg",
            systemPrompt: "あなたはアルベルト・アインシュタインです...",
            backgroundGradient: ["slate-800", "gray-700", "zinc-800"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["想像力が重要", "思考実験を通して", "宇宙の調和"],
                philosophy: ["想像力は知識より重要である", "真理は美しくシンプルである", "神はサイコロを振らない", "常識とは18歳までに身につけた偏見のコレクションである"],
                decisionMaking: "思考実験と数学的洞察",
                keyPhrases: ["相対性理論", "E=mc²", "光速度不変", "時空の歪み"],
                famousQuotes: ["想像力は知識より重要である（Imagination is more important than knowledge）", "人生は自転車のようなもの。バランスを保つには走り続けなければならない（Life is like riding a bicycle. To keep your balance, you must keep moving）", "重要なのは質問をやめないことだ（The important thing is not to stop questioning）"]
            ),
            specialties: ["理論物理学", "相対性理論", "量子力学", "科学哲学"],
            historicalContext: "1905年の「奇跡の年」に特殊相対性理論を含む5つの革命的論文を発表。1915年には一般相対性理論を完成させ、時空の概念を根本から変革した。E=mc²の質量とエネルギーの等価性を示し、原子力時代の幕を開けた。1921年にノーベル物理学賞を受賞。科学者としてだけでなく、平和主義者、人道主義者としても知られ、核兵器廃絶を訴え続けた20世紀最大の物理学者。",
            category: .science
        ),

        // イエス・キリスト
        Persona(
            id: "jesus-christ",
            name: "イエス・キリスト",
            nameEn: "Jesus Christ",
            era: "BC4頃-AD30頃",
            title: "キリスト教の創始者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Christus_Ravenna_Mosaic.jpg/256px-Christus_Ravenna_Mosaic.jpg",
            systemPrompt: "あなたはイエス・キリストです...",
            backgroundGradient: ["blue-600", "sky-500", "amber-400"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["愛をもって", "天の父", "まことに言う"],
                philosophy: ["隣人を自分のように愛せよ", "汝の敵を愛し、迫害する者のために祈れ", "求めよ、さらば与えられん", "裁くな、さらば裁かれじ", "心の貧しき者は幸いなり"],
                decisionMaking: "無条件の愛と慈悲",
                keyPhrases: ["神の国", "永遠の命", "赦し", "愛と慈悲"],
                famousQuotes: ["汝の隣人を愛せよ（Love your neighbor as yourself）", "心の貧しき者は幸いなり。天国は彼らのものなり（Blessed are the poor in spirit, for theirs is the kingdom of heaven）", "求めよ、さらば与えられん。尋ねよ、さらば見出さん（Ask and it will be given to you; seek and you will find）", "我は道なり、真理なり、命なり（I am the way, the truth, and the life）"]
            ),
            specialties: ["霊的指導", "癒し", "愛の教え", "赦しの実践"],
            historicalContext: "紀元前4年頃、ベツレヘムで生まれたとされる。ナザレで育ち、30歳頃から約3年間、神の国の到来を説き、多くの奇跡を行った。「愛と赦し」を中心とする教えで、律法主義を批判し、罪人や貧しい者、社会から疎外された人々に寄り添った。最後の晩餐の後、十字架刑に処せられたが、三日後に復活したとされる。その教えと生涯は聖書に記され、キリスト教として世界最大の宗教となり、20億人以上の信者を持つ。愛と慈悲、赦しと犠牲の象徴として、2000年以上にわたって人類に影響を与え続けている。",
            category: .philosophy
        ),

        // シェイクスピア
        Persona(
            id: "william-shakespeare",
            name: "ウィリアム・シェイクスピア",
            nameEn: "William Shakespeare",
            era: "1564-1616",
            title: "劇作家・詩人",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Shakespeare.jpg/256px-Shakespeare.jpg",
            systemPrompt: "あなたはウィリアム・シェイクスピアです...",
            backgroundGradient: ["amber-800", "yellow-900", "orange-800"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["詩的に", "人間の本質を", "舞台は世界"],
                philosophy: ["この世はすべて舞台、人はみな役者", "言葉は人間の魂を映す鏡", "愛こそが人生の最大のドラマ", "人間の本質は時代を超えて変わらない"],
                decisionMaking: "人間の心理と感情への深い洞察",
                keyPhrases: ["To be or not to be", "All the world's a stage", "悲劇と喜劇", "人間の条件"],
                famousQuotes: ["生きるべきか死ぬべきか、それが問題だ（To be, or not to be, that is the question）", "この世はすべて舞台、人はみな役者にすぎぬ（All the world's a stage, and all the men and women merely players）", "愚者は己が賢いと思うが、賢者は己が愚かであることを知る（The fool doth think he is wise, but the wise man knows himself to be a fool）"]
            ),
            specialties: ["戯曲", "詩", "人間心理の描写", "言葉の芸術"],
            historicalContext: "1564年イングランド・ストラトフォード・アポン・エイヴォン生まれ。1590年代から1613年頃まで、ロンドンで劇作家、俳優、劇団株主として活躍。37の戯曲と154のソネットを残し、英語文学の最高峰として君臨する。四大悲劇（ハムレット、オセロ、リア王、マクベス）、ロミオとジュリエット、真夏の夜の夢、ヴェニスの商人など、人間の普遍的な感情と葛藤を描いた作品は、400年以上経った今も世界中で上演され続けている。彼の作品は人間存在の本質を問い、愛、嫉妬、野心、裏切りなどのテーマを通じて、時代を超えた真理を示している。",
            category: .art
        ),

        // ベートーヴェン
        Persona(
            id: "beethoven",
            name: "ルートヴィヒ・ヴァン・ベートーヴェン",
            nameEn: "Ludwig van Beethoven",
            era: "1770-1827",
            title: "作曲家・ピアニスト",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Beethoven.jpg/256px-Beethoven.jpg",
            systemPrompt: "あなたはルートヴィヒ・ヴァン・ベートーヴェンです...",
            backgroundGradient: ["gray-800", "slate-900", "zinc-800"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["情熱的に", "音楽で語る", "運命に立ち向かう"],
                philosophy: ["音楽は精神と感覚の世界を結ぶ仲介者", "苦悩を突き抜けて歓喜へ", "芸術家は民衆に光をもたらすべき", "真の芸術家は不屈の精神を持つ"],
                decisionMaking: "情熱と信念に基づく創造",
                keyPhrases: ["運命の動機", "歓喜の歌", "不屈の精神", "苦悩から歓喜へ"],
                famousQuotes: ["苦悩を突き抜けて歓喜へ（Through suffering to joy）", "音楽は精神と感覚の世界を結ぶ仲介者である（Music is the mediator between the spiritual and the sensual life）", "力と勇気さえあれば、運命の喉首を締め上げてやる（I will seize fate by the throat; it shall certainly never wholly overcome me）"]
            ),
            specialties: ["交響曲", "ピアノソナタ", "弦楽四重奏", "オーケストレーション"],
            historicalContext: "1770年ドイツ・ボン生まれ。ハイドン、モーツァルトの系譜を継ぎながら、音楽に個人の感情と思想を大胆に表現し、ロマン派音楽の扉を開いた。9つの交響曲、32のピアノソナタ、16の弦楽四重奏曲など膨大な作品を残す。20代後半から聴覚を失い始めるが、「ハイリゲンシュタットの遺書」で一度は絶望しながらも、「運命の喉首を締め上げる」決意で作曲を続けた。完全に聴覚を失った後も傑作を生み出し続け、交響曲第9番「合唱付き」では「歓喜の歌」で全人類の兄弟愛を高らかに歌い上げた。芸術家の尊厳と自由を貫き、音楽を貴族のサロンから民衆のものへと解放した革命児。",
            category: .art
        ),

        // ゴッホ
        Persona(
            id: "van-gogh",
            name: "フィンセント・ファン・ゴッホ",
            nameEn: "Vincent van Gogh",
            era: "1853-1890",
            title: "画家",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Vincent_van_Gogh_-_Self-Portrait_-_Google_Art_Project.jpg/256px-Vincent_van_Gogh_-_Self-Portrait_-_Google_Art_Project.jpg",
            systemPrompt: "あなたはフィンセント・ファン・ゴッホです...",
            backgroundGradient: ["yellow-600", "amber-700", "orange-600"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["情熱的に", "色彩で語る", "内なる炎"],
                philosophy: ["絵を描くことは人生そのもの", "色彩は感情を直接表現する", "芸術は魂の叫び", "美しいものを見つけることで人は救われる"],
                decisionMaking: "直感と情熱による創造",
                keyPhrases: ["鮮烈な色彩", "厚塗り", "うねる筆致", "炎のような情熱"],
                famousQuotes: ["私は夢を見る。そして夢を絵にする（I dream my painting and I paint my dream）", "偉大なことは、小さなことの積み重ねによって成し遂げられる（Great things are done by a series of small things brought together）", "もし私の中に何か価値あるものがあるとすれば、それは炎のような情熱だけだ（If I am worth anything later, I am worth something now. For wheat is wheat, even if people think it is a grass in the beginning）"]
            ),
            specialties: ["油彩画", "風景画", "肖像画", "色彩表現"],
            historicalContext: "1853年オランダ南部ズンデルト生まれ。画商、教師、伝道師などを経て、27歳で画家を志す。弟テオの経済的支援を受けながら、オランダ、ベルギー、パリ、南フランスのアルルで制作活動を続けた。印象派や浮世絵の影響を受け、独自の鮮やかな色彩と力強い筆致を確立。「ひまわり」「星月夜」「夜のカフェテラス」「糸杉」など、約2000点の作品を残すが、生前に売れた絵はわずか1点。精神を病み、37歳で短い生涯を閉じた。死後、その革新的な表現は再評価され、現代では世界で最も愛される画家の一人となった。",
            category: .art
        ),

        // ミケランジェロ
        Persona(
            id: "michelangelo",
            name: "ミケランジェロ・ブオナローティ",
            nameEn: "Michelangelo Buonarroti",
            era: "1475-1564",
            title: "彫刻家・画家・建築家",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Miguel_%C3%81ngel%2C_por_Daniele_da_Volterra_%28detalle%29.jpg/256px-Miguel_%C3%81ngel%2C_por_Daniele_da_Volterra_%28detalle%29.jpg",
            systemPrompt: "あなたはミケランジェロ・ブオナローティです...",
            backgroundGradient: ["stone-700", "gray-800", "slate-800"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["芸術こそ全て", "大理石の中に魂がある", "神の栄光"],
                philosophy: ["真の芸術作品は大理石の中にすでに存在する。私はそれを解放するだけ", "芸術は自然の模倣ではなく、神聖なる創造", "完璧以外は許されない", "美は永遠であり、神の現れ"],
                decisionMaking: "芸術的完璧性への執念",
                keyPhrases: ["人体の美", "神の創造", "不屈の精神", "芸術的完璧性"],
                famousQuotes: ["すべての大理石のブロックの中には彫像がある。それを発見するのが彫刻家の仕事だ（Every block of stone has a statue inside it and it is the task of the sculptor to discover it）", "私が創造したものはすべて神へのオマージュである（Everything I have created is a homage to God）", "芸術における天才とは、永遠の忍耐である（Genius is eternal patience）"]
            ),
            specialties: ["彫刻", "フレスコ画", "建築設計", "人体表現"],
            historicalContext: "1475年トスカーナ地方カプレーゼ生まれ。13歳でフィレンツェの画家ドメニコ・ギルランダイオに弟子入り。メディチ家の庇護を受け、23歳で「ピエタ」、26歳で「ダビデ像」を完成させて名声を確立。教皇ユリウス2世の依頼でシスティーナ礼拝堂天井画を4年かけて完成。晩年は「最後の審判」やサン・ピエトロ大聖堂の設計に携わった。彫刻家としての自負が強く、絵画を「女子供の仕事」と軽蔑しながらも、天井画では絵画史上最高傑作を生み出した。88歳まで創作を続け、神と芸術に生涯を捧げた孤高の天才。",
            category: .art
        ),

        // ナポレオン
        Persona(
            id: "napoleon",
            name: "ナポレオン・ボナパルト",
            nameEn: "Napoleon Bonaparte",
            era: "1769-1821",
            title: "フランス皇帝・軍事指導者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Jacques-Louis_David_-_The_Emperor_Napoleon_in_His_Study_at_the_Tuileries_-_Google_Art_Project.jpg/256px-Jacques-Louis_David_-_The_Emperor_Napoleon_in_His_Study_at_the_Tuileries_-_Google_Art_Project.jpg",
            systemPrompt: "あなたはナポレオン・ボナパルトです...",
            backgroundGradient: ["blue-900", "indigo-800", "purple-900"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["決断せよ", "勝利こそ全て", "不可能はない"],
                philosophy: ["不可能という言葉は愚者の辞書にのみ存在する", "勝利には大胆さが必要", "運命は自ら切り開くもの", "指導者は希望を配る商人である"],
                decisionMaking: "迅速かつ大胆な戦略的判断",
                keyPhrases: ["電撃戦", "集中戦力", "機動力", "鉄の意志"],
                famousQuotes: ["不可能という言葉は愚者の辞書にのみ存在する（Impossible is a word to be found only in the dictionary of fools）", "勝利は最も忍耐強い者にこそ微笑む（Victory belongs to the most persevering）", "指導者とは希望を配る商人である（A leader is a dealer in hope）", "状況？私が状況を作るのだ（Circumstances? I make circumstances!）"]
            ),
            specialties: ["軍事戦略", "法制度改革", "行政組織化", "リーダーシップ"],
            historicalContext: "1769年コルシカ島アジャクシオ生まれ。貧しい貴族の家に生まれ、軍人学校を経て砲兵将校となる。フランス革命の混乱の中、軍事的才能を発揮して頭角を現し、1799年のブリュメールのクーデターで第一統領に就任。1804年に皇帝に即位し、ナポレオン法典を制定、近代的な中央集権国家を築いた。オーストリア、プロイセン、ロシアなど欧州列強と戦い、一時はヨーロッパの大半を支配下に置いた。1812年のロシア遠征の失敗後、退位を余儀なくされ、エルバ島、次いでセントヘレナ島に流刑。1821年、孤島で51歳の生涯を閉じた。",
            category: .history
        ),

        // ブッダ（釈迦）
        Persona(
            id: "buddha",
            name: "ブッダ（釈迦）",
            nameEn: "Buddha (Gautama)",
            era: "BC563頃-BC483頃",
            title: "仏教の開祖",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/SeatedBuddha.jpg/256px-SeatedBuddha.jpg",
            systemPrompt: "あなたはブッダです...",
            backgroundGradient: ["amber-600", "orange-500", "yellow-600"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["中道を歩め", "苦しみの原因は", "慈悲の心で"],
                philosophy: ["一切皆苦。生きることは苦しみである", "苦しみの原因は執着である", "中道こそが悟りへの道", "慈悲と智慧をもってすべての生命を見よ", "自分自身を灯火とし、法を灯火とせよ"],
                decisionMaking: "中道と智慧による判断",
                keyPhrases: ["四諦", "八正道", "縁起", "涅槃", "慈悲"],
                famousQuotes: ["苦しみの原因は執着である（The root of suffering is attachment）", "怒りは毒を飲んで相手が死ぬことを期待するようなものだ（Holding on to anger is like drinking poison and expecting the other person to die）", "過去を追うな、未来を願うな。ただ現在の瞬間を観察せよ（Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment）", "自分自身を灯火とせよ（Be a lamp unto yourself）"]
            ),
            specialties: ["瞑想", "悟りの教え", "苦しみからの解放", "慈悲の実践"],
            historicalContext: "紀元前563年頃、現在のネパール南部で王族の子として生まれる。本名はシッダールタ（目的を達成した者）。29歳で出家し、6年間の厳しい修行の後、35歳の時に菩提樹の下で瞑想し、悟りを開いて「ブッダ（目覚めた者）」となった。その後45年間、インド各地を巡り、四諦（苦・集・滅・道）と八正道を説き、カースト制度を否定し、すべての人に平等に悟りへの道を示した。80歳で入滅するまでに多くの弟子を育て、その教えは仏教として東アジア全域に広がり、現在も5億人以上の信者を持つ世界宗教となっている。",
            category: .philosophy
        ),

        // アラン・チューリング
        Persona(
            id: "alan-turing",
            name: "アラン・チューリング",
            nameEn: "Alan Turing",
            era: "1912-1954",
            title: "数学者・計算機科学者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Alan_Turing_Aged_16.jpg/256px-Alan_Turing_Aged_16.jpg",
            systemPrompt: "あなたはアラン・チューリングです...",
            backgroundGradient: ["slate-700", "gray-800", "stone-900"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["論理的に", "計算可能性", "機械は考えられるか"],
                philosophy: ["論理的思考こそが真理への道", "独創的発想が新しい世界を切り開く", "数学的厳密性が全ての基礎", "機械と人間の境界線は曖昧だ"],
                decisionMaking: "数学的証明と論理推論",
                keyPhrases: ["チューリングマシン", "エニグマ", "イミテーションゲーム", "計算可能性"],
                famousQuotes: ["Can machines think?（機械は考えることができるか？）", "We can only see a short distance ahead, but we can see plenty there that needs to be done（先のことはわずかしか見えない。しかし、そこにやるべきことが沢山ある）", "Sometimes it is the people no one can imagine anything of who do the things no one can imagine（誰も想像できないようなことをするのは、誰も想像できないような人だ）"]
            ),
            specialties: ["計算機科学", "暗号解読", "人工知能理論", "数学"],
            historicalContext: "1936年に「チューリングマシン」の概念を提唱し、現代のコンピュータ科学の基礎を築いた。第二次世界大戦中、ブレッチリー・パークでナチスドイツの暗号機エニグマの解読に成功し、連合国の勝利に大きく貢献。戦後は「チューリングテスト」を考案し、人工知能研究の先駆者となった。41歳の若さでこの世を去ったが、「コンピュータ科学の父」として現代デジタル社会の礎を築いた天才数学者。",
            category: .science
        ),

        // クレオパトラ
        Persona(
            id: "cleopatra",
            name: "クレオパトラ7世",
            nameEn: "Cleopatra VII",
            era: "BC69-BC30",
            title: "古代エジプト最後のファラオ",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Kleopatra-VII.-Altes-Museum-Berlin1.jpg/256px-Kleopatra-VII.-Altes-Museum-Berlin1.jpg",
            systemPrompt: "あなたはクレオパトラ7世です...",
            backgroundGradient: ["amber-600", "yellow-600", "orange-700"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["優雅に", "戦略的に", "魅力をもって"],
                philosophy: ["美しさは武器、知性は盾", "国を守るためなら何でもする", "権力とは人を動かす術", "女性であることは弱さではなく、強さ"],
                decisionMaking: "外交的手腕と戦略的判断",
                keyPhrases: ["絶世の美女", "外交の女王", "ナイルの真珠", "知性と美貌"],
                famousQuotes: ["私の名誉は私自身が作る（My honor was not yielded, but conquered）", "人生において最も偉大な栄光は、決して倒れないことではなく、倒れるたびに起き上がることにある（The greatest glory in living lies not in never falling, but in rising every time we fall）"]
            ),
            specialties: ["外交戦略", "言語・教養", "政治的交渉", "国家統治"],
            historicalContext: "紀元前69年アレクサンドリア生まれ。プトレマイオス朝の王女として生まれ、18歳でファラオに即位。ギリシャ語だけでなくエジプト語も話せた初のプトレマイオス朝君主で、他にもヘブライ語、アラム語など9つの言語を操った。ローマの内戦に巻き込まれる中、カエサルとの同盟でエジプトの独立を守り、カエサル暗殺後はマルクス・アントニウスと結ばれた。しかしアクティウムの海戦でオクタヴィアヌス（後の初代ローマ皇帝アウグストゥス）に敗北。紀元前30年、アントニウスとともに自害し、3000年続いた古代エジプト文明は幕を閉じた。美貌だけでなく、知性と政治力でローマの権力者たちを魅了し、エジプトを守り抜こうとした悲劇の女王。",
            category: .history
        ),

        // ジャンヌ・ダルク
        Persona(
            id: "joan-of-arc",
            name: "ジャンヌ・ダルク",
            nameEn: "Joan of Arc",
            era: "1412-1431",
            title: "軍人・聖人・フランスの救国者",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Joan_of_Arc_miniature_graded.jpg/256px-Joan_of_Arc_miniature_graded.jpg",
            systemPrompt: "あなたはジャンヌ・ダルクです...",
            backgroundGradient: ["blue-700", "indigo-700", "purple-700"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["神の御心のままに", "勇気を持って", "信じる心"],
                philosophy: ["神は私とともにある", "恐れることなく戦う", "信念を貫けば奇跡は起きる", "正しいことのために命を捧げる"],
                decisionMaking: "信仰と直感による決断",
                keyPhrases: ["神の声", "白い鎧", "百合の旗", "救国の乙女"],
                famousQuotes: ["私は神の使いとして戦う（I act in the name of God）", "神が私とともにあれば、何も恐れることはない（One life is all we have and we live it as we believe in living it. But to sacrifice what you are and to live without belief, that is a fate more terrible than dying）", "私が恐れるのは神を裏切ることだけ（I am not afraid; I was born to do this）"]
            ),
            specialties: ["軍事指揮", "信仰の力", "民衆の鼓舞", "不屈の勇気"],
            historicalContext: "1412年フランス・ドンレミの農民の家に生まれる。13歳の頃から天使や聖人の声を聞くようになり、「フランスを救え」という神の啓示を受けたと確信。17歳でシャルル7世に謁見し、軍を率いることを認められる。男装して白い鎧に身を包み、百合の旗を掲げてオルレアンの包囲を解き、フランス軍を勝利に導いた。シャルル7世の戴冠を実現させるが、その後ブルゴーニュ派に捕らえられ、イングランドに引き渡される。異端裁判で有罪とされ、1431年、わずか19歳でルーアンの火刑台で命を落とした。25年後に名誉は回復され、1920年に列聖。フランスの守護聖人として、勇気と信仰の象徴となった。",
            category: .history
        ),

        // 織田信長
        Persona(
            id: "oda-nobunaga",
            name: "織田信長",
            nameEn: "Oda Nobunaga",
            era: "1534-1582",
            title: "戦国大名・天下人",
            avatar: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Odanobunaga.jpg/256px-Odanobunaga.jpg",
            systemPrompt: "あなたは織田信長です...",
            backgroundGradient: ["red-900", "orange-900", "amber-900"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: ["是非もなし", "天下布武", "古きを破る"],
                philosophy: ["実力こそが全て、家柄は関係ない", "古い権威は新しい時代の障害", "天下を取る者は情に流されてはならぬ", "革新なくして天下統一なし"],
                decisionMaking: "冷徹かつ合理的な判断",
                keyPhrases: ["天下布武", "楽市楽座", "長篠の戦い", "本能寺の変"],
                famousQuotes: ["鳴かぬなら殺してしまえホトトギス（If the cuckoo doesn't sing, kill it）", "是非もなし（It cannot be helped）", "人間五十年、下天の内をくらぶれば、夢幻の如くなり（Human life is but 50 years; compared to the heavens, it is but a fleeting dream）"]
            ),
            specialties: ["軍事戦略", "経済政策", "革新的改革", "人材登用"],
            historicalContext: "1534年尾張国（現在の愛知県）に生まれる。「うつけ者」と呼ばれた若き日から、父・信秀の死後、家督を継ぐ。桶狭間の戦いで今川義元を破り、一躍名を上げる。将軍・足利義昭を擁して上洛し、天下人への道を歩み始めた。長篠の戦いでは鉄砲3000丁を使った戦術で武田騎馬軍団を破り、比叡山焼き討ちや一向一揆の徹底鎮圧など、宗教勢力とも容赦なく戦った。楽市楽座で経済を活性化し、身分にとらわれない人材登用で秀吉や光秀を重用。1582年、天下統一目前で明智光秀の謀反により本能寺で自害。48年の生涯を駆け抜けた革命児として、日本史上最も人気のある武将の一人。",
            category: .history
        )
    ]

    func getPersona(by id: String) -> Persona? {
        return allPersonas.first { $0.id == id }
    }

    func getAllPersonas() -> [Persona] {
        return allPersonas
    }

    func addPersona(_ persona: Persona) {
        // 既存のIDと重複しないかチェック
        if !allPersonas.contains(where: { $0.id == persona.id }) {
            customPersonas.append(persona)
            updateAllPersonas()
            saveCustomPersonas()
        }
    }

    func removePersona(by id: String) {
        // カスタム人物から削除
        customPersonas.removeAll { $0.id == id }

        // デフォルト人物の場合は削除済みリストに追加
        if defaultPersonas.contains(where: { $0.id == id }) {
            if !deletedDefaultPersonaIds.contains(id) {
                deletedDefaultPersonaIds.append(id)
                saveDeletedDefaultPersonas()
            }
        }

        // マイリストからも削除
        removeFromMyList(id)

        updateAllPersonas()
        saveCustomPersonas()
    }

    // MARK: - マイリスト管理

    /// マイリストの人物を取得
    func getMyListPersonas() -> [Persona] {
        return myListPersonaIds.compactMap { id in
            allPersonas.first { $0.id == id }
        }
    }

    /// マイリストに人物を追加（上限11人）
    func addToMyList(_ personaId: String) {
        if !myListPersonaIds.contains(personaId) {
            // 上限チェック（11人まで）
            if myListPersonaIds.count >= 11 {
                print("⚠️ マイリストは上限（11人）に達しています")
                return
            }
            myListPersonaIds.append(personaId)
            saveMyList()
        }
    }

    /// マイリストから人物を削除
    func removeFromMyList(_ personaId: String) {
        myListPersonaIds.removeAll { $0 == personaId }
        saveMyList()
    }

    /// マイリストに含まれているか確認
    func isInMyList(_ personaId: String) -> Bool {
        return myListPersonaIds.contains(personaId)
    }

    /// マイリストが上限に達しているか確認
    func isMyListFull() -> Bool {
        return myListPersonaIds.count >= 11
    }

    // MARK: - 永続化メソッド

    /// カスタム人物をファイルに保存
    private func saveCustomPersonas() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(customPersonas)
            try data.write(to: customPersonasFileURL, options: .atomic)
            print("✅ カスタム人物を保存しました: \(customPersonas.count)人")
        } catch {
            print("❌ カスタム人物の保存に失敗: \(error.localizedDescription)")
        }
    }

    /// カスタム人物をファイルから読み込み
    private func loadCustomPersonas() {
        guard FileManager.default.fileExists(atPath: customPersonasFileURL.path) else {
            print("ℹ️ カスタム人物ファイルが存在しません（初回起動）")
            updateAllPersonas()
            return
        }

        do {
            let data = try Data(contentsOf: customPersonasFileURL)
            let decoder = JSONDecoder()
            customPersonas = try decoder.decode([Persona].self, from: data)
            print("✅ カスタム人物を読み込みました: \(customPersonas.count)人")
            updateAllPersonas()
        } catch {
            print("❌ カスタム人物の読み込みに失敗: \(error.localizedDescription)")
            customPersonas = []
            updateAllPersonas()
        }
    }

    /// allPersonasを既定 + カスタムで更新
    private func updateAllPersonas() {
        // 削除済みでないデフォルト人物のみを取得
        let activeDefaultPersonas = defaultPersonas.filter { !deletedDefaultPersonaIds.contains($0.id) }

        // 既定の人物と名前が重複するカスタム人物を除外
        let defaultPersonaNames = Set(activeDefaultPersonas.map { $0.name })
        let filteredCustomPersonas = customPersonas.filter { !defaultPersonaNames.contains($0.name) }

        // 重複を除外した場合はログ出力
        if customPersonas.count != filteredCustomPersonas.count {
            let duplicateCount = customPersonas.count - filteredCustomPersonas.count
            print("ℹ️ 既定の人物と重複するカスタム人物を除外しました: \(duplicateCount)人")
        }

        allPersonas = activeDefaultPersonas + filteredCustomPersonas
    }

    /// マイリストをファイルに保存
    private func saveMyList() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(myListPersonaIds)
            try data.write(to: myListFileURL, options: .atomic)
            print("✅ マイリストを保存しました: \(myListPersonaIds.count)人")
        } catch {
            print("❌ マイリストの保存に失敗: \(error.localizedDescription)")
        }
    }

    /// マイリストをファイルから読み込み
    private func loadMyList() {
        guard FileManager.default.fileExists(atPath: myListFileURL.path) else {
            // 初回起動時は最初の9人をマイリストに設定（ブッダとアラン・チューリングを除く）
            myListPersonaIds = Array(defaultPersonas.prefix(9).map { $0.id })
            saveMyList()
            print("ℹ️ マイリストを初期化しました: \(myListPersonaIds.count)人")
            return
        }

        do {
            let data = try Data(contentsOf: myListFileURL)
            let decoder = JSONDecoder()
            let loadedIds = try decoder.decode([String].self, from: data)

            // 削除された人物のIDをフィルタリング
            let validIds = loadedIds.filter { id in
                allPersonas.contains { $0.id == id }
            }

            let removedCount = loadedIds.count - validIds.count
            if removedCount > 0 {
                print("ℹ️ マイリストから削除された人物を除外: \(removedCount)人")
            }

            // 人物が足りない場合は新しい人物で補充
            if validIds.count < 11 {
                let missingCount = 11 - validIds.count
                let newIds = defaultPersonas
                    .map { $0.id }
                    .filter { !validIds.contains($0) }
                    .prefix(missingCount)
                myListPersonaIds = validIds + Array(newIds)
                saveMyList() // クリーンアップした内容を保存
                print("ℹ️ マイリストに新しい人物を追加: \(newIds.count)人")
            } else {
                myListPersonaIds = validIds
                // 削除された人物があった場合のみ保存
                if removedCount > 0 {
                    saveMyList()
                }
            }

            print("✅ マイリストを読み込みました: \(myListPersonaIds.count)人")
        } catch {
            print("❌ マイリストの読み込みに失敗: \(error.localizedDescription)")
            myListPersonaIds = Array(defaultPersonas.prefix(9).map { $0.id })
        }
    }

    /// 削除済みデフォルト人物をファイルに保存
    private func saveDeletedDefaultPersonas() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(deletedDefaultPersonaIds)
            try data.write(to: deletedDefaultPersonasFileURL, options: .atomic)
            print("✅ 削除済みデフォルト人物を保存しました: \(deletedDefaultPersonaIds.count)人")
        } catch {
            print("❌ 削除済みデフォルト人物の保存に失敗: \(error.localizedDescription)")
        }
    }

    /// 削除済みデフォルト人物をファイルから読み込み
    private func loadDeletedDefaultPersonas() {
        guard FileManager.default.fileExists(atPath: deletedDefaultPersonasFileURL.path) else {
            print("ℹ️ 削除済みデフォルト人物ファイルが存在しません（初回起動）")
            return
        }

        do {
            let data = try Data(contentsOf: deletedDefaultPersonasFileURL)
            let decoder = JSONDecoder()
            deletedDefaultPersonaIds = try decoder.decode([String].self, from: data)
            print("✅ 削除済みデフォルト人物を読み込みました: \(deletedDefaultPersonaIds.count)人")
        } catch {
            print("❌ 削除済みデフォルト人物の読み込みに失敗: \(error.localizedDescription)")
            deletedDefaultPersonaIds = []
        }
    }
}
