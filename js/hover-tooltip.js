// Floating hover tooltip for .link-with-hover-tooltip elements.
//
// Each element holds a <template class="hover-tooltip-content"> (see the
// xslt-func-link shortcode). On hover/focus its content is cloned into one shared
// tooltip <div> on <body>, positioned next to the link. Because the tooltip lives
// on <body> it can contain block elements and is never clipped by overflow.
(() => {
    const SHOW_DELAY_MS = 300;
    const GAP = 10;            // px between link and tooltip (includes the arrow)
    const VIEWPORT_MARGIN = 8; // min px between tooltip and the viewport edge
    const TOP_CLEARANCE = 60;  // height of the fixed top navbar
    const TIP_ID = 'hover-tooltip';

    let tip = null;
    let timer = null;
    let currentLink = null;

    const findWrap = (el) =>
        el && el.closest ? el.closest('.link-with-hover-tooltip') : null;

    function getTip() {
        if (!tip) {
            tip = document.createElement('div');
            tip.id = TIP_ID;
            tip.className = 'hover-tooltip';
            tip.setAttribute('role', 'tooltip');
            document.body.appendChild(tip);
        }
        return tip;
    }

    function show(wrap) {
        const tpl = wrap.querySelector(':scope > template.hover-tooltip-content');
        if (!tpl) return;

        const t = getTip();
        t.replaceChildren(tpl.content.cloneNode(true));
        t.classList.remove('hover-tooltip--below');

        // The tooltip is laid out (just not visible) so we can measure it.
        const link = wrap.getBoundingClientRect();
        const size = t.getBoundingClientRect();
        const viewportWidth = document.documentElement.clientWidth;

        // Centre on the link but keep it inside the viewport
        const linkCentre = link.left + link.width / 2;
        let left = linkCentre - size.width / 2;
        left = Math.max(VIEWPORT_MARGIN, Math.min(left, viewportWidth - size.width - VIEWPORT_MARGIN));

        // Prefer above the link, fall back to below if it would go under the navbar
        const below = link.top - size.height - GAP < TOP_CLEARANCE;
        const top = below ? link.bottom + GAP : link.top - size.height - GAP;

        // Keep the arrow pointing at the link, away from the rounded corners
        const arrowLeft = Math.max(16, Math.min(linkCentre - left, size.width - 16));

        t.style.left = `${left + window.scrollX}px`;
        t.style.top = `${top + window.scrollY}px`;
        t.style.setProperty('--tooltip-arrow-left', `${arrowLeft}px`);
        t.classList.toggle('hover-tooltip--below', below);
        t.classList.add('is-visible');

        const a = wrap.querySelector('a');
        if (a) a.setAttribute('aria-describedby', TIP_ID);
        currentLink = a;
    }

    function hide() {
        clearTimeout(timer);
        timer = null;
        if (tip) tip.classList.remove('is-visible');
        if (currentLink) currentLink.removeAttribute('aria-describedby');
        currentLink = null;
    }

    document.addEventListener('mouseover', (e) => {
        const wrap = findWrap(e.target);
        if (wrap && !wrap.contains(e.relatedTarget)) {
            hide();
            timer = setTimeout(() => show(wrap), SHOW_DELAY_MS);
        }
    });

    document.addEventListener('mouseout', (e) => {
        const wrap = findWrap(e.target);
        if (wrap && !wrap.contains(e.relatedTarget)) hide();
    });

    // Keyboard users
    document.addEventListener('focusin', (e) => {
        const wrap = findWrap(e.target);
        if (wrap) { hide(); show(wrap); }
    });
    document.addEventListener('focusout', (e) => { if (findWrap(e.target)) hide(); });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') hide(); });
    window.addEventListener('resize', hide);
})();
