/* ==========================================================================
   济南奶龙职业技术学院 · 官网交互
   原生 JS，无依赖
   ========================================================================== */
(function () {
  'use strict';

  /* ---------------------------------------------------------------
     1. 首屏图片轮播
     --------------------------------------------------------------- */
  function initHero() {
    var slides = Array.prototype.slice.call(document.querySelectorAll('.hero__slide'));
    var dots   = Array.prototype.slice.call(document.querySelectorAll('.hero__dot'));
    if (slides.length < 2) return;

    var current = 0;
    var timer   = null;
    var DELAY   = 6500;

    function show(next) {
      next = (next + slides.length) % slides.length;
      if (next === current) return;

      slides[current].classList.remove('is-on');
      dots[current] && (dots[current].classList.remove('is-on'),
                        dots[current].setAttribute('aria-selected', 'false'));

      slides[next].classList.add('is-on');
      dots[next] && (dots[next].classList.add('is-on'),
                     dots[next].setAttribute('aria-selected', 'true'));

      current = next;
    }

    function start() { stop(); timer = window.setInterval(function () { show(current + 1); }, DELAY); }
    function stop()  { if (timer) { window.clearInterval(timer); timer = null; } }

    dots.forEach(function (dot, i) {
      dot.addEventListener('click', function () { show(i); start(); });
    });

    // 页面切到后台时不空转
    document.addEventListener('visibilitychange', function () {
      document.hidden ? stop() : start();
    });

    // 鼠标悬停时暂停
    var hero = document.querySelector('.hero');
    if (hero) {
      hero.addEventListener('mouseenter', stop);
      hero.addEventListener('mouseleave', start);
    }

    start();
  }

  /* ---------------------------------------------------------------
     2. 移动端菜单
     --------------------------------------------------------------- */
  function initNav() {
    var toggle = document.querySelector('.nav__toggle');
    var menu   = document.getElementById('nav-menu');
    if (!toggle || !menu) return;

    function setOpen(open) {
      menu.classList.toggle('is-open', open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    toggle.addEventListener('click', function () {
      setOpen(!menu.classList.contains('is-open'));
    });

    // 点击菜单项后收起
    menu.addEventListener('click', function (e) {
      if (e.target.closest('a')) setOpen(false);
    });

    // 视口变宽后重置
    window.addEventListener('resize', function () {
      if (window.innerWidth > 820) setOpen(false);
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') setOpen(false);
    });
  }

  /* ---------------------------------------------------------------
     3. 院系搜索过滤
     --------------------------------------------------------------- */
  function initSearch() {
    var input = document.getElementById('q');
    var list  = document.getElementById('cards');
    var empty = document.getElementById('cardsEmpty');
    if (!input || !list) return;

    var cards = Array.prototype.slice.call(list.children);

    function apply() {
      var term = input.value.trim().toLowerCase();
      var shown = 0;

      cards.forEach(function (card) {
        var hit = !term || card.textContent.toLowerCase().indexOf(term) !== -1;
        card.hidden = !hit;
        if (hit) shown++;
      });

      if (empty) empty.hidden = shown !== 0;
    }

    input.addEventListener('input', apply);
    input.addEventListener('search', apply);

    // 回车后跳到院系区
    var form = input.closest('form');
    if (form) {
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        apply();
        var target = document.getElementById('departments');
        if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    }
  }

  /* ---------------------------------------------------------------
     4. 滚动时高亮当前栏目
     --------------------------------------------------------------- */
  function initScrollSpy() {
    var links = Array.prototype.slice.call(document.querySelectorAll('.nav__menu a[href^="#"]'));
    if (!links.length || !('IntersectionObserver' in window)) return;

    var map = {};
    var sections = [];

    links.forEach(function (link) {
      var id = link.getAttribute('href').slice(1);
      var el = document.getElementById(id);
      if (!el) return;
      map[id] = link;
      sections.push(el);
    });

    var visible = {};

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        visible[entry.target.id] = entry.isIntersecting ? entry.intersectionRatio : 0;
      });

      var bestId = null, bestRatio = 0;
      Object.keys(visible).forEach(function (id) {
        if (visible[id] > bestRatio) { bestRatio = visible[id]; bestId = id; }
      });

      if (!bestId) return;
      links.forEach(function (l) { l.classList.remove('is-active'); });
      map[bestId] && map[bestId].classList.add('is-active');
    }, {
      rootMargin: '-25% 0px -55% 0px',
      threshold: [0, 0.15, 0.3, 0.5, 0.75, 1]
    });

    sections.forEach(function (s) { observer.observe(s); });
  }

  /* ---------------------------------------------------------------
     5. 导航栏滚动阴影
     --------------------------------------------------------------- */
  function initNavShadow() {
    var nav = document.getElementById('nav');
    if (!nav) return;
    var onScroll = function () {
      nav.style.boxShadow = window.scrollY > 8
        ? '0 6px 22px rgba(11,36,80,.28)'
        : '0 2px 10px rgba(11,36,80,.18)';
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* ---------------------------------------------------------------
     启动
     --------------------------------------------------------------- */
  function boot() {
    initHero();
    initNav();
    initSearch();
    initScrollSpy();
    initNavShadow();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
