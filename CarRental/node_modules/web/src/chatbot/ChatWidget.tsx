import React, { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MessageCircle, X, Send, Trash2, Bot } from 'lucide-react';
import { useChatStore } from '../store';
import { mockRespond } from './mockRespond';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';

// ── Typing Indicator (3 bouncing dots) ────────────────────────────
const TypingIndicator: React.FC = () => (
  <div className="flex gap-1 px-4 py-3" aria-label="VANTA is typing">
    {[0, 1, 2].map((i) => (
      <span
        key={i}
        className="w-1.5 h-1.5 rounded-full bg-vanta-ink-muted"
        style={{ animation: `chatTyping 1.4s ease-in-out ${i * 0.18}s infinite` }}
      />
    ))}
  </div>
);

// ── Message Bubble ────────────────────────────────────────────────
const MessageBubble: React.FC<{
  role: 'user' | 'assistant';
  text: string;
  isTyping?: boolean;
}> = ({ role, text, isTyping }) => {
  const isUser = role === 'user';

  // Render markdown-lite (bold and newlines)
  const renderText = (raw: string) => {
    return raw.split('\n').map((line, i) => (
      <React.Fragment key={i}>
        {line.split(/(\*\*[^*]+\*\*)/g).map((part, j) =>
          part.startsWith('**') && part.endsWith('**') ? (
            <strong key={j} className="font-semibold">{part.slice(2, -2)}</strong>
          ) : (
            <span key={j}>{part}</span>
          )
        )}
        {i < raw.split('\n').length - 1 && <br />}
      </React.Fragment>
    ));
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10, scale: 0.97 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ duration: 0.3, ease: ease.elegant }}
      className={cn('flex gap-2 max-w-[85%]', isUser ? 'ml-auto flex-row-reverse' : '')}
    >
      {!isUser && (
        <div className="w-7 h-7 rounded-full bg-vanta-amber/15 border border-vanta-amber/30 flex items-center justify-center shrink-0 mt-auto">
          <Bot size={13} className="text-vanta-amber" />
        </div>
      )}
      <div
        className={cn(
          'rounded-2xl text-[13px] leading-relaxed font-sans',
          isUser
            ? 'bg-vanta-amber text-white px-4 py-2.5 rounded-tr-md'
            : 'bg-vanta-panel border border-vanta-border text-vanta-ink px-4 py-2.5 rounded-tl-md'
        )}
      >
        {isTyping ? <TypingIndicator /> : renderText(text)}
      </div>
    </motion.div>
  );
};

// ── Main Chat Widget ──────────────────────────────────────────────
export const ChatWidget: React.FC = () => {
  const { isOpen, setOpen, messages, addMessage, isTyping, setTyping, clearHistory } = useChatStore();
  const [input, setInput] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isTyping]);

  // Focus input when chat opens
  useEffect(() => {
    if (isOpen && inputRef.current) {
      setTimeout(() => inputRef.current?.focus(), 350);
    }
  }, [isOpen]);

  // Welcome message on first open
  useEffect(() => {
    if (isOpen && messages.length === 0) {
      setTimeout(() => {
        addMessage({
          role: 'assistant',
          text: "Hello! I'm Falcon View's AI concierge 👋\n\nAsk me anything — fleet availability, pricing, insurance, or delivery options. I'm here to help.",
        });
      }, 400);
    }
  }, [isOpen]);

  const handleSend = useCallback(async () => {
    const text = input.trim();
    if (!text || isTyping) return;

    setInput('');

    // Add user message
    addMessage({ role: 'user', text });

    // Show typing indicator
    setTyping(true);

    try {
      // TODO: Replace mockRespond() with real API call to /api/chat
      const response = await mockRespond(text);
      setTyping(false);
      addMessage({ role: 'assistant', text: response });
    } catch {
      setTyping(false);
      addMessage({ role: 'assistant', text: 'Sorry, I encountered an issue. Please try again or contact our concierge team directly.' });
    }
  }, [input, isTyping, addMessage, setTyping]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <>
      {/* ── FAB Button ── */}
      <motion.button
        onClick={() => setOpen(!isOpen)}
        whileHover={{ scale: 1.08, y: -2 }}
        whileTap={{ scale: 0.94 }}
        className="fixed bottom-6 right-6 z-[950] w-14 h-14 rounded-full bg-vanta-amber text-white flex items-center justify-center shadow-amber-glow"
        aria-label={isOpen ? 'Close chat' : 'Open SAFRA concierge chat'}
        aria-expanded={isOpen}
      >
        <AnimatePresence mode="wait">
          {isOpen ? (
            <motion.span key="close" initial={{ rotate: -90, opacity: 0 }} animate={{ rotate: 0, opacity: 1 }} exit={{ rotate: 90, opacity: 0 }} transition={{ duration: 0.2 }}>
              <X size={20} />
            </motion.span>
          ) : (
            <motion.span key="open" initial={{ scale: 0, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0, opacity: 0 }} transition={{ duration: 0.2 }}>
              <MessageCircle size={20} />
            </motion.span>
          )}
        </AnimatePresence>

        {/* Unread dot — only shown before first open */}
        {!isOpen && messages.length === 0 && (
          <motion.span
            className="absolute top-1 right-1 w-2.5 h-2.5 bg-red-500 rounded-full border border-white shadow-sm"
            animate={{ scale: [1, 1.15, 1] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
        )}
      </motion.button>

      {/* ── Chat Window ── */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            key="chat-window"
            initial={{ opacity: 0, scale: 0.92, y: 20, originX: 1, originY: 1 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.92, y: 20 }}
            transition={{ duration: duration.normal, ease: ease.spring }}
            className="fixed bottom-24 right-6 z-[940] w-[340px] sm:w-[380px] flex flex-col bg-vanta-paper border border-vanta-border rounded-2xl shadow-card-xl overflow-hidden"
            role="dialog"
            aria-label="SAFRA AI Concierge"
            aria-modal="true"
            style={{ maxHeight: '560px' }}
          >
            {/* Header */}
            <div className="flex items-center justify-between px-5 py-4 bg-vanta-panel border-b border-vanta-border">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-full bg-vanta-amber-pale border border-vanta-amber/30 flex items-center justify-center">
                  <Bot size={16} className="text-vanta-amber" />
                </div>
                <div>
                  <p className="font-grotesk font-semibold text-[13px] text-vanta-ink">SAFRA Concierge</p>
                  <div className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-vanta-success" />
                    <span className="font-mono text-[9px] uppercase tracking-[0.12em] text-vanta-ink-muted">Online — 24/7</span>
                  </div>
                </div>
              </div>
              <button
                onClick={clearHistory}
                className="w-7 h-7 rounded-md flex items-center justify-center text-vanta-ink-subtle hover:text-vanta-danger hover:bg-vanta-danger/10 transition-colors"
                aria-label="Clear chat history"
              >
                <Trash2 size={13} />
              </button>
            </div>

            {/* Messages */}
            <div
              data-lenis-prevent
              className="flex-1 overflow-y-auto p-4 flex flex-col gap-3 no-scrollbar"
              style={{ minHeight: 200, maxHeight: 380 }}
              role="log"
              aria-live="polite"
            >
              {messages.map((msg) => (
                <MessageBubble key={msg.id} role={msg.role} text={msg.text} />
              ))}

              {isTyping && (
                <motion.div
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="flex gap-2 max-w-[85%]"
                >
                  <div className="w-7 h-7 rounded-full bg-vanta-amber/15 border border-vanta-amber/30 flex items-center justify-center shrink-0 mt-auto">
                    <Bot size={13} className="text-vanta-amber" />
                  </div>
                  <div className="bg-vanta-panel border border-vanta-border rounded-2xl rounded-tl-md">
                    <TypingIndicator />
                  </div>
                </motion.div>
              )}

              <div ref={messagesEndRef} />
            </div>

            {/* Input */}
            <div className="px-4 py-3 bg-vanta-panel border-t border-vanta-border">
              <div className="flex items-center gap-2 bg-vanta-paper border border-vanta-border rounded-xl px-4 py-2.5 focus-within:border-vanta-amber transition-colors">
                <input
                  ref={inputRef}
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder="Ask about fleet, pricing, delivery..."
                  className="flex-1 bg-transparent text-[13px] font-sans text-vanta-ink placeholder:text-vanta-ink-subtle focus:outline-none"
                  aria-label="Type your message"
                  disabled={isTyping}
                  maxLength={300}
                />
                <motion.button
                  onClick={handleSend}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  disabled={!input.trim() || isTyping}
                  className={cn(
                    'w-7 h-7 rounded-lg flex items-center justify-center transition-all',
                    input.trim() && !isTyping
                      ? 'bg-vanta-amber text-white shadow-amber-sm'
                      : 'bg-vanta-border text-vanta-ink-subtle cursor-not-allowed'
                  )}
                  aria-label="Send message"
                >
                  <Send size={13} />
                </motion.button>
              </div>
              <p className="font-mono text-[9px] text-vanta-ink-subtle text-center mt-2 tracking-[0.1em]">
                AI responses are for guidance only — always verify with our team
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

export default ChatWidget;
