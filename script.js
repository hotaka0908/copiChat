class DTalkBot {
    constructor() {
        this.messages = document.getElementById('messages');
        this.messageInput = document.getElementById('messageInput');
        this.sendButton = document.getElementById('sendButton');
        this.modelSelect = document.getElementById('modelSelect');
        
        this.setupEventListeners();
        this.setupTextareaResize();
    }

    setupEventListeners() {
        this.sendButton.addEventListener('click', () => this.sendMessage());
        
        this.messageInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        this.messageInput.addEventListener('input', () => {
            this.updateSendButtonState();
        });

        this.updateSendButtonState();
    }

    setupTextareaResize() {
        this.messageInput.addEventListener('input', () => {
            this.messageInput.style.height = 'auto';
            this.messageInput.style.height = Math.min(this.messageInput.scrollHeight, 200) + 'px';
        });
    }

    updateSendButtonState() {
        const hasText = this.messageInput.value.trim().length > 0;
        this.sendButton.disabled = !hasText;
        this.sendButton.classList.toggle('active', hasText);
    }

    async sendMessage() {
        const text = this.messageInput.value.trim();
        if (!text) return;

        this.addMessage(text, 'user');
        this.messageInput.value = '';
        this.messageInput.style.height = 'auto';
        this.updateSendButtonState();

        this.showTyping();

        try {
            const response = await this.getAIResponse(text);
            this.removeTyping();
            this.addMessage(response, 'assistant');
        } catch (error) {
            this.removeTyping();
            this.addMessage('申し訳ございません。エラーが発生しました。', 'assistant');
        }
    }

    addMessage(text, sender) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;

        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        const avatarIcon = document.createElement('div');
        avatarIcon.className = 'avatar-icon';
        if (sender === 'user') {
            avatarIcon.textContent = 'You';
        } else {
            const selectedModel = this.modelSelect.value;
            avatarIcon.textContent = selectedModel === 'mother-teresa' ? 'MT' : 'AI';
        }
        avatar.appendChild(avatarIcon);

        const content = document.createElement('div');
        content.className = 'message-content';
        const p = document.createElement('p');
        p.textContent = text;
        content.appendChild(p);

        messageDiv.appendChild(avatar);
        messageDiv.appendChild(content);

        this.messages.appendChild(messageDiv);
        this.scrollToBottom();
    }

    showTyping() {
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message assistant-message typing-message';
        typingDiv.id = 'typing-indicator';

        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        const avatarIcon = document.createElement('div');
        avatarIcon.className = 'avatar-icon';
        const selectedModel = this.modelSelect.value;
        avatarIcon.textContent = selectedModel === 'mother-teresa' ? 'MT' : 'AI';
        avatar.appendChild(avatarIcon);

        const content = document.createElement('div');
        content.className = 'message-content';
        const typingIndicator = document.createElement('div');
        typingIndicator.className = 'typing-indicator';
        typingIndicator.innerHTML = '<span></span><span></span><span></span>';
        content.appendChild(typingIndicator);

        typingDiv.appendChild(avatar);
        typingDiv.appendChild(content);

        this.messages.appendChild(typingDiv);
        this.scrollToBottom();
    }

    removeTyping() {
        const typingMessage = document.getElementById('typing-indicator');
        if (typingMessage) {
            typingMessage.remove();
        }
    }

    async getAIResponse(userMessage) {
        await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 2000));

        const selectedModel = this.modelSelect.value;
        
        let responses;
        if (selectedModel === 'mother-teresa') {
            responses = [
                '愛は小さなことから始まります。あなたの優しさが世界を変えるのです。',
                '神は私たちに成功を求めているのではありません。忠実であることを求めているのです。',
                '微笑みは愛の始まりです。互いに微笑み合いましょう。',
                '私たちは大きなことはできません。ただ、小さなことを大きな愛をもって行うだけです。',
                '最も悲しいことは、愛されないことではなく、愛することを忘れることです。',
                '平和は微笑みから始まります。',
                'あなたの中にある愛を、周りの人々と分かち合ってください。',
                '助けを必要としている人を見過ごさないでください。それが私たちの使命です。'
            ];
        } else {
            responses = [
                'とても興味深い質問ですね。詳しく教えていただけますか？',
                'その点について考えてみましょう。いくつかの観点があります。',
                'なるほど、理解しました。私の考えをお伝えします。',
                'それは重要なポイントですね。以下のように整理できると思います。',
                'ご質問ありがとうございます。この件について説明させていただきます。',
                'その通りですね。追加の情報があれば、より具体的にお答えできます。',
                '興味深いトピックです。さらに詳しく掘り下げてみましょう。',
                'そのご質問にお答えします。まず基本的な点から説明します。'
            ];
        }
        let modelPrefix = '';
        
        switch(selectedModel) {
            case 'gpt-3.5':
                modelPrefix = '[GPT-3.5] ';
                break;
            case 'gpt-4':
                modelPrefix = '[GPT-4] ';
                break;
            case 'claude':
                modelPrefix = '[Claude] ';
                break;
            case 'mother-teresa':
                modelPrefix = '[マザー・テレサ] ';
                break;
        }

        return modelPrefix + responses[Math.floor(Math.random() * responses.length)];
    }

    scrollToBottom() {
        setTimeout(() => {
            this.messages.scrollTop = this.messages.scrollHeight;
        }, 100);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new DTalkBot();
});