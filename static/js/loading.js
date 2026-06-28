/* ===== Loading Utilities ===== */

// --- Top Progress Bar ---
(function() {
    var bar = document.createElement('div');
    bar.className = 'top-progress';
    bar.id = 'top-progress';
    document.body.prepend(bar);

    function resetBar() {
        bar.classList.remove('active');
        bar.classList.add('done');
        setTimeout(function() {
            bar.classList.remove('done');
            bar.style.width = '0';
        }, 600);
    }

    // Show progress bar on link clicks (page navigation)
    document.addEventListener('click', function(e) {
        var link = e.target.closest('a[href]');
        if (!link) return;
        var href = link.getAttribute('href');
        // Skip hash links, javascript:, new tabs, and same-page anchors
        if (!href || href.startsWith('#') || href.startsWith('javascript:') ||
            link.target === '_blank' || link.hasAttribute('download')) return;
        // Skip if modifier key held (opening in new tab)
        if (e.ctrlKey || e.metaKey || e.shiftKey) return;

        try {
            var targetUrl = new URL(href, window.location.origin);
            var currentPath = window.location.pathname.replace(/\/$/, '') || '/';
            var targetPath = targetUrl.pathname.replace(/\/$/, '') || '/';
            if (targetPath === currentPath && targetUrl.hash) {
                resetBar();
                return;
            }
        } catch (error) {}

        bar.classList.remove('done');
        bar.style.width = '';
        bar.classList.add('active');
    });

    // Complete bar when page is fully loaded (for back/forward nav)
    window.addEventListener('pageshow', function() {
        resetBar();
    });

    window.addEventListener('hashchange', function() {
        resetBar();
    });
})();

// --- Button Loading State ---
function btnLoading(btn, text) {
    if (!btn) return;
    btn.classList.add('is-loading');
    btn.setAttribute('data-original-text', btn.innerHTML);
    if (text) {
        btn.innerHTML = '<span class="loading-spinner-sm"></span>' + text;
        btn.style.visibility = 'visible';
    }
}

function btnReset(btn) {
    if (!btn) return;
    btn.classList.remove('is-loading');
    var orig = btn.getAttribute('data-original-text');
    if (orig) btn.innerHTML = orig;
    btn.removeAttribute('data-original-text');
}

// --- Skeleton Screen Helper ---
function showSkeleton(containerId, type, count) {
    var container = document.getElementById(containerId);
    if (!container) return;
    var html = '';
    count = count || 4;
    for (var i = 0; i < count; i++) {
        if (type === 'stat') {
            html += '<div class="skeleton skeleton-stat"></div>';
        } else if (type === 'table') {
            html += '<div class="skeleton skeleton-table-row"></div>';
        } else if (type === 'card') {
            html += '<div class="skeleton skeleton-card"></div>';
        } else if (type === 'product') {
            html += '<div class="skeleton skeleton-product"></div>';
        } else if (type === 'chart') {
            html += '<div class="skeleton skeleton-chart"></div>';
        }
    }
    container.innerHTML = html;
}

function hideSkeleton(containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;
    var skeletons = container.querySelectorAll('.skeleton');
    skeletons.forEach(function(el) { el.remove(); });
}
