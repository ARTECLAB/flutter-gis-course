/* ═══════════════════════════════════════════════════════════════
   ARTECLAB · Curso Flutter GIS — JS Centralizado
   Tabs, Copy Code, Checklist, Quiz
   ═══════════════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {

  /* ── Tabs ─────────────────────────────────────────── */
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.dataset.target;
      const wrap = btn.closest('.site-wrapper') || document;

      wrap.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      wrap.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const panel = document.getElementById(id);
      if (panel) panel.classList.add('active');
    });
  });

  /* ── Copy code ───────────────────────────────────── */
  document.querySelectorAll('.codeblock-copy').forEach(btn => {
    btn.addEventListener('click', () => {
      const pre = btn.closest('.codeblock').querySelector('pre');
      const text = pre.textContent;

      navigator.clipboard.writeText(text).then(() => {
        btn.textContent = '✓ Copiado';
        btn.classList.add('done');
        setTimeout(() => { btn.textContent = 'Copiar'; btn.classList.remove('done'); }, 2000);
      }).catch(() => {
        const ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        btn.textContent = '✓ Copiado';
        btn.classList.add('done');
        setTimeout(() => { btn.textContent = 'Copiar'; btn.classList.remove('done'); }, 2000);
      });
    });
  });

  /* ── Checklist ───────────────────────────────────── */
  document.querySelectorAll('.checklist li').forEach(li => {
    li.addEventListener('click', () => {
      li.classList.toggle('done');
      const box = li.querySelector('.ck-box');
      box.textContent = li.classList.contains('done') ? '✓' : '';
    });
  });

  /* ── Quiz system ─────────────────────────────────── */
  document.querySelectorAll('.quiz').forEach(quiz => {
    const questions = quiz.querySelectorAll('.quiz-q');
    const submitBtn = quiz.querySelector('.quiz-submit');
    const resultEl = quiz.querySelector('.quiz-result');
    const picks = {};

    quiz.querySelectorAll('.quiz-opt').forEach(opt => {
      opt.addEventListener('click', () => {
        const qi = opt.closest('.quiz-q').dataset.qi;
        opt.closest('.quiz-opts').querySelectorAll('.quiz-opt').forEach(o => o.classList.remove('picked'));
        opt.classList.add('picked');
        picks[qi] = opt.dataset.val;
      });
    });

    if (submitBtn) {
      submitBtn.addEventListener('click', () => {
        let score = 0;
        const total = questions.length;

        questions.forEach(q => {
          const qi = q.dataset.qi;
          const ans = q.dataset.ans;
          const fb = q.querySelector('.quiz-fb');
          const opts = q.querySelectorAll('.quiz-opt');

          opts.forEach(o => o.classList.remove('right', 'wrong'));

          if (picks[qi] === ans) {
            score++;
            opts.forEach(o => { if (o.dataset.val === ans) o.classList.add('right'); });
            if (fb) { fb.className = 'quiz-fb show ok'; fb.textContent = '✓ ¡Correcto!'; }
          } else {
            opts.forEach(o => {
              if (o.dataset.val === ans) o.classList.add('right');
              if (o.classList.contains('picked')) o.classList.add('wrong');
            });
            if (fb) {
              fb.className = 'quiz-fb show nope';
              fb.textContent = '✗ ' + (q.dataset.explain || 'Incorrecto');
            }
          }
        });

        if (resultEl) {
          const pct = Math.round((score / total) * 100);
          resultEl.textContent = `Resultado: ${score}/${total} (${pct}%)`;
          if (pct >= 70) {
            resultEl.className = 'quiz-result show pass';
            resultEl.textContent += ' — ¡Buen trabajo! 🎉';
          } else {
            resultEl.className = 'quiz-result show fail';
            resultEl.textContent += ' — Repasa y vuelve a intentar 💪';
          }
        }

        quiz.querySelectorAll('.quiz-opt').forEach(o => o.style.pointerEvents = 'none');
        submitBtn.style.display = 'none';
      });
    }
  });

});



/* ═══════════════════════════════════════════════════════════════
   ARTECLAB · Curso Flutter GIS — JS Centralizado
   Tabs, Copy Code, Checklist, Quiz
   ═══════════════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {

  /* ── Tabs ─────────────────────────────────────────── */
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.dataset.target;
      const wrap = btn.closest('.site-wrapper') || document;

      wrap.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      wrap.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const panel = document.getElementById(id);
      if (panel) panel.classList.add('active');
    });
  });

  /* ── Copy code ───────────────────────────────────── */
  document.querySelectorAll('.codeblock-copy').forEach(btn => {
    btn.addEventListener('click', () => {
      const pre = btn.closest('.codeblock').querySelector('pre');
      const text = pre.textContent;

      navigator.clipboard.writeText(text).then(() => {
        btn.textContent = '✓ Copiado';
        btn.classList.add('done');
        setTimeout(() => { btn.textContent = 'Copiar'; btn.classList.remove('done'); }, 2000);
      }).catch(() => {
        const ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        btn.textContent = '✓ Copiado';
        btn.classList.add('done');
        setTimeout(() => { btn.textContent = 'Copiar'; btn.classList.remove('done'); }, 2000);
      });
    });
  });

  /* ── Checklist ───────────────────────────────────── */
  document.querySelectorAll('.checklist li').forEach(li => {
    li.addEventListener('click', () => {
      li.classList.toggle('done');
      const box = li.querySelector('.ck-box');
      box.textContent = li.classList.contains('done') ? '✓' : '';
    });
  });

  /* ── Quiz system ─────────────────────────────────── */
  document.querySelectorAll('.quiz').forEach(quiz => {
    const questions = quiz.querySelectorAll('.quiz-q');
    const submitBtn = quiz.querySelector('.quiz-submit');
    const resultEl = quiz.querySelector('.quiz-result');
    const picks = {};

    quiz.querySelectorAll('.quiz-opt').forEach(opt => {
      opt.addEventListener('click', () => {
        const qi = opt.closest('.quiz-q').dataset.qi;
        opt.closest('.quiz-opts').querySelectorAll('.quiz-opt').forEach(o => o.classList.remove('picked'));
        opt.classList.add('picked');
        picks[qi] = opt.dataset.val;
      });
    });

    if (submitBtn) {
      submitBtn.addEventListener('click', () => {
        let score = 0;
        const total = questions.length;

        questions.forEach(q => {
          const qi = q.dataset.qi;
          const ans = q.dataset.ans;
          const fb = q.querySelector('.quiz-fb');
          const opts = q.querySelectorAll('.quiz-opt');

          opts.forEach(o => o.classList.remove('right', 'wrong'));

          if (picks[qi] === ans) {
            score++;
            opts.forEach(o => { if (o.dataset.val === ans) o.classList.add('right'); });
            if (fb) { fb.className = 'quiz-fb show ok'; fb.textContent = '✓ ¡Correcto!'; }
          } else {
            opts.forEach(o => {
              if (o.dataset.val === ans) o.classList.add('right');
              if (o.classList.contains('picked')) o.classList.add('wrong');
            });
            if (fb) {
              fb.className = 'quiz-fb show nope';
              fb.textContent = '✗ ' + (q.dataset.explain || 'Incorrecto');
            }
          }
        });

        if (resultEl) {
          const pct = Math.round((score / total) * 100);
          resultEl.textContent = `Resultado: ${score}/${total} (${pct}%)`;
          if (pct >= 70) {
            resultEl.className = 'quiz-result show pass';
            resultEl.textContent += ' — ¡Buen trabajo! 🎉';
          } else {
            resultEl.className = 'quiz-result show fail';
            resultEl.textContent += ' — Repasa y vuelve a intentar 💪';
          }
        }

        quiz.querySelectorAll('.quiz-opt').forEach(o => o.style.pointerEvents = 'none');
        submitBtn.style.display = 'none';
      });
    }
  });

  /* ── Protección de código fuente ──────────────── */
  /* Solo bloquea acceso al código fuente del sitio.
     NO bloquea: copiar texto, seleccionar, links, imprimir.
     El estudiante puede usar el sitio con normalidad. */

  document.addEventListener('keydown', function(e) {
    // Ctrl+U = ver código fuente
    if (e.ctrlKey && e.key === 'u') { e.preventDefault(); return; }
    // Ctrl+Shift+I = DevTools (Elements)
    if (e.ctrlKey && e.shiftKey && e.key === 'I') { e.preventDefault(); return; }
    // Ctrl+Shift+J = DevTools (Console)
    if (e.ctrlKey && e.shiftKey && e.key === 'J') { e.preventDefault(); return; }
    // Ctrl+Shift+C = DevTools (Inspector)
    if (e.ctrlKey && e.shiftKey && e.key === 'C') { e.preventDefault(); return; }
    // F12 = DevTools
    if (e.key === 'F12') { e.preventDefault(); return; }
    // Ctrl+S = guardar página como archivo
    if (e.ctrlKey && e.key === 's') { e.preventDefault(); return; }
  });

  // Bloquear clic derecho solo para evitar "Ver código fuente"
  document.addEventListener('contextmenu', function(e) {
    e.preventDefault();
  });

});


