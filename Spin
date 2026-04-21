import React, { useState, useRef } from 'react';
import { LucideTrophy, LucideTicket, LucideTrees, LucideGamepad2, LucideGhost, LucideCoins } from 'lucide-react';

// Google Apps Script Web App URL
const SCRIPT_URL = "https://script.google.com/macros/s/AKfycbx0Iy0uqS4-rcYZXtwj5sieQ2TEl0sBN3zE7TENp4j9Jt-3FB2jLjrH2KPZMH-pX5kjvA/exec";

const PRIZES = [
  { label: 'ဗလာ', color: '#94a3b8', probability: 0.95 },
  { label: 'ဘောနပ်စ် 5000', color: '#fbbf24', probability: 0.01 },
  { label: 'ဘောနပ်စ် 10000', color: '#f59e0b', probability: 0.01 },
  { label: 'ဘောနပ်စ် 20000', color: '#ea580c', probability: 0.01 },
  { label: 'ဘောနပ်စ် 50000', color: '#dc2626', probability: 0.01 },
  { label: 'ဘောနပ်စ် 100000', color: '#7c3aed', probability: 0.01 },
];

export default function App() {
  const [promoCode, setPromoCode] = useState('');
  const [isSpinning, setIsSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [result, setResult] = useState(null);
  const [message, setMessage] = useState({ type: '', text: '' });

  const handleSpin = async () => {
    if (isSpinning || !promoCode.trim()) return;

    setMessage({ type: 'info', text: 'Code ကို စစ်ဆေးနေပါသည်...' });

    try {
      // 1. Code ရှိမရှိ စစ်ဆေးခြင်း
      const response = await fetch(`${SCRIPT_URL}?code=${promoCode.trim()}`);
      const data = await response.json();

      if (data.status !== "success") {
        setMessage({ type: 'error', text: 'မှားယွင်းနေသော သို့မဟုတ် အသုံးပြုပြီးသား Code ဖြစ်ပါသည်' });
        return;
      }

      // 2. Prize ရွေးချယ်ခြင်း
      const rand = Math.random();
      let cumulativeProb = 0;
      let winningIndex = 0;

      for (let i = 0; i < PRIZES.length; i++) {
        cumulativeProb += PRIZES[i].probability;
        if (rand <= cumulativeProb) {
          winningIndex = i;
          break;
        }
      }

      // 3. Animation စတင်ခြင်း
      setIsSpinning(true);
      setMessage({ type: 'info', text: 'Free Bonus ကံစမ်းနေပါသည်' });
      
      const extraSpins = 10;
      const sectionAngle = 360 / PRIZES.length;
      const targetRotation = rotation + (extraSpins * 360) + (360 - (winningIndex * sectionAngle)) - (rotation % 360);
      setRotation(targetRotation);

      // 4. ဒေတာ သိမ်းဆည်းခြင်း
      setTimeout(async () => {
        try {
          await fetch(SCRIPT_URL, {
            method: "POST",
            mode: 'no-cors', 
            body: JSON.stringify({
              row: data.row,
              code: promoCode,
              prize: PRIZES[winningIndex].label
            })
          });

          setIsSpinning(false);
          setResult(PRIZES[winningIndex]);
          
          const prizeLabel = PRIZES[winningIndex].label;

          if (prizeLabel === 'ဗလာ') {
            setMessage({ type: 'error', text: 'စိတ်မကောင်းပါဘူး။ သင် ဗလာကျသွားပါတယ်' });
          } else {
            const amount = prizeLabel.replace('ဘောနပ်စ် ', '');
            setMessage({ type: 'success', text: `ဂုဏ်ယူပါတယ်။သင် ဘောနပ်စ် ${amount} ရရှိပါသည်` });
          }
          
          setPromoCode('');
        } catch (e) {
          console.error("Update error:", e);
          setIsSpinning(false);
          setMessage({ type: 'error', text: 'ဒေတာသိမ်းဆည်းမှု အဆင်မပြေပါ။' });
        }
      }, 4000);

    } catch (error) {
      console.error("Error:", error);
      setMessage({ type: 'error', text: 'ချိတ်ဆက်မှု အဆင်မပြေပါ။ Code URL ကို စစ်ဆေးပါ။' });
    }
  };

  return (
    <div className="min-h-screen bg-emerald-900 text-white flex flex-col items-center justify-center p-4 font-sans relative overflow-hidden">
      {/* Background Decor */}
      <div className="absolute inset-0 opacity-20 pointer-events-none">
        <div className="absolute top-10 left-10"><LucideTrees size={100} /></div>
        <div className="absolute bottom-10 right-10"><LucideTrees size={120} /></div>
        <div className="absolute top-1/2 left-1/4 animate-bounce"><LucideGamepad2 size={40} /></div>
      </div>

      <div className="z-10 bg-black/40 backdrop-blur-md p-8 rounded-3xl border-4 border-emerald-500 shadow-2xl max-w-md w-full text-center">
        <h1 className="text-3xl font-bold mb-2 flex items-center justify-center gap-2">
          <LucideTrophy className="text-yellow-400" /> Free Bonus Spin
        </h1>
        {/* စာသားအသစ် ပြင်ဆင်ထားသည့်နေရာ */}
        <p className="text-emerald-200 text-sm mb-6">သင့်ဆီပို့ပေးထားသော Free Bonus Code ဖြင့် ကံစမ်းပါ</p>

        {/* The Wheel */}
        <div className="relative w-64 h-64 mx-auto mb-8">
          <div className="absolute -top-4 left-1/2 -translate-x-1/2 z-20 text-yellow-400">
            <div className="w-0 h-0 border-l-[15px] border-l-transparent border-r-[15px] border-r-transparent border-t-[30px] border-t-current"></div>
          </div>
          
          <div 
            className="w-full h-full rounded-full border-8 border-yellow-600 shadow-xl relative overflow-hidden transition-transform duration-[4000ms] cubic-bezier(0.15, 0, 0.15, 1)"
            style={{ transform: `rotate(${rotation}deg)` }}
          >
            {PRIZES.map((prize, index) => {
              const angle = 360 / PRIZES.length;
              return (
                <div
                  key={index}
                  className="absolute top-0 left-0 w-full h-full origin-center flex items-start justify-center pt-4"
                  style={{ 
                    transform: `rotate(${index * angle}deg)`,
                    backgroundColor: prize.color,
                    clipPath: `polygon(50% 50%, 0% 0%, 100% 0%)`,
                    width: '100%',
                    height: '100%'
                  }}
                >
                  <div className="text-[10px] font-bold mt-4 text-white uppercase drop-shadow-md">
                    {prize.label}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-10 h-10 bg-yellow-600 border-4 border-yellow-400 rounded-full z-10 shadow-lg"></div>
        </div>

        {/* Input Area */}
        <div className="space-y-4">
          <div className="relative">
            <LucideTicket className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-400" size={20} />
            <input 
              type="text" 
              placeholder="Code ရိုက်ထည့်ပါ..."
              value={promoCode}
              onChange={(e) => setPromoCode(e.target.value.toUpperCase())}
              disabled={isSpinning}
              className="w-full bg-emerald-950/50 border-2 border-emerald-500 rounded-xl py-3 pl-10 pr-4 outline-none focus:ring-2 ring-emerald-400 text-white transition-all"
            />
          </div>

          <button
            onClick={handleSpin}
            disabled={isSpinning || !promoCode}
            className={`w-full py-4 rounded-xl font-bold text-xl shadow-lg transition-all ${
              isSpinning || !promoCode 
              ? 'bg-gray-600 opacity-50 cursor-not-allowed' 
              : 'bg-gradient-to-r from-yellow-500 to-orange-600 text-white active:scale-95 hover:shadow-yellow-500/20 hover:shadow-xl'
            }`}
          >
            {isSpinning ? 'Free Bonus ကံစမ်းနေပါသည်' : 'SPIN လှည့်မည်'}
          </button>
        </div>

        {message.text && (
          <div className={`mt-6 p-3 rounded-lg text-sm border animate-pulse-slow ${
            message.type === 'success' ? 'bg-green-500/20 text-green-300 border-green-500' :
            message.type === 'error' ? 'bg-red-500/20 text-red-300 border-red-500' :
            'bg-blue-500/20 text-blue-300 border-blue-500'
          }`}>
            {message.text}
          </div>
        )}
      </div>
    </div>
  );
}
