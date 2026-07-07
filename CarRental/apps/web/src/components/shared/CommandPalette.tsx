import React, { useState, useEffect } from 'react';

interface CommandPaletteProps {
  onClose: () => void;
  openCompare: () => void;
  toggleTheme: () => void;
  openBookingModal: (name: string) => void;
}

const COMMANDS = [
  { label: "Go to Fleet", type: "section", actionId: "fleet" },
  { label: "Go to Membership", type: "section", actionId: "membership" },
  { label: "Go to Corporate Partner sales", type: "section", actionId: "corporate" },
  { label: "Open Compare Drawer", type: "action", actionId: "compare" },
  { label: "Toggle Theme (Light / Dark Mode)", type: "action", actionId: "theme" },
  { label: "Book the Vantage GT", type: "action", actionId: "book" }
];

const CommandPalette: React.FC<CommandPaletteProps> = ({ onClose, openCompare, toggleTheme, openBookingModal }) => {
  const [query, setQuery] = useState('');

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const filtered = COMMANDS.filter(cmd => cmd.label.toLowerCase().includes(query.toLowerCase()));

  const handleAction = (cmd: typeof COMMANDS[0]) => {
    onClose();
    if (cmd.type === 'section') {
      document.getElementById(cmd.actionId)?.scrollIntoView({ behavior: 'smooth' });
    } else {
      if (cmd.actionId === 'compare') openCompare();
      if (cmd.actionId === 'theme') toggleTheme();
      if (cmd.actionId === 'book') openBookingModal("Vantage GT");
    }
  };

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-md z-[990] flex items-start justify-center pt-24 px-4">
      <div className="bg-panel border border-border w-full max-w-[560px] rounded-m shadow-2xl overflow-hidden animate-[fadeIn_0.2s_ease]">
        <input 
          type="text" 
          placeholder="Type a command or query... (Esc to close)" 
          value={query}
          onChange={e => setQuery(e.target.value)}
          className="w-full bg-transparent border-b border-border p-5 text-text-heading placeholder-text-muted focus:outline-none"
          autoFocus
        />
        <div className="max-h-[280px] overflow-y-auto p-2 flex flex-col">
          {filtered.length === 0 ? (
            <div className="text-text-muted text-sm p-4 text-center">No commands found.</div>
          ) : (
            filtered.map((cmd, idx) => (
              <button 
                key={idx}
                onClick={() => handleAction(cmd)}
                className="w-full text-left p-3 hover:bg-primary/10 hover:text-primary rounded-md text-sm text-text-main flex justify-between items-center transition-colors"
              >
                {cmd.label}
                <span className="font-mono text-[10px] text-text-muted uppercase tracking-wider">{cmd.type}</span>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default CommandPalette;
