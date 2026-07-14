// ===== UTC Date Helper =====
// Server always returns UTC datetimes. Append 'Z' so JS treats them as UTC.
function parseUTC(dtStr) {
    if (!dtStr) return null;
    // Already has timezone info
    if (dtStr.endsWith('Z') || /[+-]\d{2}:\d{2}$/.test(dtStr)) return new Date(dtStr);
    // Bare datetime from MySQL — treat as UTC
    return new Date(dtStr.replace(' ', 'T') + 'Z');
}

// ===== Inline Form Validation =====
function validateField(inputEl, message) {
    var el = typeof inputEl === 'string' ? document.getElementById(inputEl) : inputEl;
    if (!el) return true;
    var val = el.tagName === 'SELECT' ? el.value : (el.value || '').trim();
    var valid = val !== '' && val !== null && val !== undefined;
    if (!valid) {
        el.classList.add('input-error');
        if (!el.nextElementSibling || !el.nextElementSibling.classList.contains('field-error')) {
            el.insertAdjacentHTML('afterend', '<div class="field-error">' + (message || 'This field is required') + '</div>');
        }
        // Auto-clear on next input/change
        var clearOnce = function() { clearFieldError(el); el.removeEventListener('input', clearOnce); el.removeEventListener('change', clearOnce); };
        el.addEventListener('input', clearOnce);
        el.addEventListener('change', clearOnce);
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
        clearFieldError(el);
    }
    return valid;
}

function clearFieldError(el) {
    if (!el) return;
    el.classList.remove('input-error');
    var next = el.nextElementSibling;
    if (next && next.classList.contains('field-error')) next.remove();
}

function clearFormErrors(formEl) {
    if (!formEl) return;
    formEl.querySelectorAll('.input-error').forEach(function(el) { el.classList.remove('input-error'); });
    formEl.querySelectorAll('.field-error').forEach(function(el) { el.remove(); });
}

// ===== Shop Icon Helpers =====
// Handles both SVG filenames (e.g. "male-clothes.svg") and legacy emoji strings.

function isShopIconSvg(icon) {
    return icon && icon.toLowerCase().endsWith('.svg');
}

function shopIconHtml(icon, size) {
    size = size || 24;
    if (isShopIconSvg(icon)) {
        return '<img src="/static/icons/shop-icons/' + icon + '" width="' + size + '" height="' + size + '" style="object-fit:contain;display:block;" alt="">';
    }
    return '<span>' + (icon || '') + '</span>';
}

// Sets the .navbar-brand-icon element — works for both SVG files and emoji.
function setNavBrandIcon(icon) {
    var bi = document.querySelector('.navbar-brand-icon');
    if (!bi) return;
    if (isShopIconSvg(icon)) {
        bi.innerHTML = '<img src="/static/icons/shop-icons/' + icon + '" style="width:22px;height:22px;object-fit:contain;display:block;" alt="">';
    } else {
        bi.textContent = icon || '';
    }
}

// ===== Modal / Drawer Scroll Lock =====
// Prevents the page from scrolling behind open modals and drawers — iOS + Android safe.
// Uses position:fixed trick (saves/restores scroll Y) so iOS Safari honours it.
var _modalScrollY = 0;
var _modalOpenCount = 0;

function lockBodyScroll() {
    if (_modalOpenCount === 0) {
        _modalScrollY = window.scrollY || window.pageYOffset;
        document.body.style.position = 'fixed';
        document.body.style.top = '-' + _modalScrollY + 'px';
        document.body.style.left = '0';
        document.body.style.right = '0';
        document.body.style.overflow = 'hidden';
    }
    _modalOpenCount++;
}

function unlockBodyScroll() {
    _modalOpenCount = Math.max(0, _modalOpenCount - 1);
    if (_modalOpenCount === 0) {
        document.body.style.position = '';
        document.body.style.top = '';
        document.body.style.left = '';
        document.body.style.right = '';
        document.body.style.overflow = '';
        window.scrollTo(0, _modalScrollY);
    }
}

// openModal / closeModal: convenience wrappers — also used directly by templates.
// The MutationObserver below handles ALL other classList.add/remove('active') calls
// automatically, so templates that haven't been updated still get scroll lock.
function openModal(id) {
    var el = document.getElementById(id);
    if (el) el.classList.add('active');
    // lock is applied by the MutationObserver
}

function closeModal(id) {
    var el = document.getElementById(id);
    if (el && el.classList.contains('active')) el.classList.remove('active');
    // unlock is applied by the MutationObserver
}

// ===== Auto scroll-lock via MutationObserver =====
// Watches the entire DOM for any .modal gaining/losing 'active',
// and any full-screen drawer (.product-drawer, sidebar-like) gaining/losing 'open'/'mobile-open'.
// This covers EVERY page without needing per-template changes.
(function () {
    // Drawers that should lock scroll only on mobile
    var DRAWER_CLASSES = ['product-drawer', 'pos-cart-panel'];
    var MOBILE_BREAKPOINT = 900;

    function isDrawerEl(el) {
        return DRAWER_CLASSES.some(function (cls) { return el.classList.contains(cls); });
    }

    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            if (mutation.type !== 'attributes' || mutation.attributeName !== 'class') return;
            var el = mutation.target;

            // --- Modals (.modal with 'active') ---
            if (el.classList.contains('modal')) {
                if (el.classList.contains('active')) {
                    lockBodyScroll();
                } else {
                    unlockBodyScroll();
                }
            }

            // --- Full-screen drawers on mobile ---
            if (isDrawerEl(el) && window.innerWidth <= MOBILE_BREAKPOINT) {
                var isOpen = el.classList.contains('open') || el.classList.contains('mobile-open');
                var wasOpen = mutation.oldValue &&
                    (mutation.oldValue.includes(' open') || mutation.oldValue.startsWith('open') ||
                     mutation.oldValue.includes('mobile-open'));
                if (isOpen && !wasOpen) {
                    lockBodyScroll();
                } else if (!isOpen && wasOpen) {
                    unlockBodyScroll();
                }
            }
        });
    });

    function startObserver() {
        observer.observe(document.body, {
            attributes: true,
            attributeFilter: ['class'],
            attributeOldValue: true,
            subtree: true
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', startObserver);
    } else {
        startObserver();
    }
})();

// ===== Toast Notification System =====
function _ensureToastContainer() {
    let c = document.getElementById('toast-container');
    if (!c) {
        c = document.createElement('div');
        c.id = 'toast-container';
        c.className = 'toast-container';
        document.body.appendChild(c);
    }
    return c;
}

function _ensureLoadingOverlay() {
    let o = document.getElementById('loading-overlay');
    if (!o) {
        o = document.createElement('div');
        o.id = 'loading-overlay';
        o.className = 'loading-overlay';
        o.innerHTML = '<div class="loading-spinner"></div>';
        document.body.appendChild(o);
    }
    return o;
}

const TOAST_ICONS = {
    success: '✓',
    error: '✕',
    warning: '⚠',
    info: 'ℹ'
};

/**
 * Show a toast notification
 * @param {string} message - The message to display
 * @param {string} type - 'success' | 'error' | 'warning' | 'info'
 * @param {number} duration - Duration in ms (default 3000)
 */
function showToast(message, type = 'info', duration = 3000) {
    const container = _ensureToastContainer();
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.style.setProperty('--toast-duration', (duration / 1000) + 's');
    toast.innerHTML = `
        <span class="toast-icon">${TOAST_ICONS[type] || 'ℹ'}</span>
        <span class="toast-message">${message}</span>
        <button class="toast-close" onclick="this.parentElement.remove()">&times;</button>
    `;
    container.appendChild(toast);

    // Remove after animation completes
    setTimeout(() => {
        if (toast.parentElement) toast.remove();
    }, duration + 300);
}

/**
 * Show loading overlay
 */
function showLoading() {
    _ensureLoadingOverlay().classList.add('active');
}

/**
 * Hide loading overlay
 */
function hideLoading() {
    _ensureLoadingOverlay().classList.remove('active');
}

// ===== Sidebar Toggle =====
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainWrapper = document.getElementById('main-wrapper');
    const overlay = document.getElementById('sidebar-overlay');
    if (!sidebar) return;

    if (window.innerWidth <= 900) {
        // Mobile: slide in/out
        sidebar.classList.toggle('mobile-open');
        if (overlay) overlay.classList.toggle('active');
    } else {
        // Desktop: collapse to icon-only
        const isCollapsed = sidebar.classList.toggle('collapsed');
        if (mainWrapper) mainWrapper.classList.toggle('sidebar-collapsed', isCollapsed);
        try { localStorage.setItem('sidebar_collapsed', isCollapsed ? '1' : '0'); } catch(e) {}
    }
}

function closeSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    if (sidebar) sidebar.classList.remove('mobile-open');
    if (overlay) overlay.classList.remove('active');
}

function bindMobileSidebarLinkClose() {
    const nav = document.querySelector('#sidebar .sidebar-nav');
    if (!nav || nav.dataset.mobileLinkCloseReady === '1') return;
    nav.dataset.mobileLinkCloseReady = '1';

    nav.addEventListener('click', function(e) {
        const link = e.target.closest('a[href]');
        if (!link) return;
        if (window.innerWidth <= 900) {
            closeSidebar();
        }
    });
}

function initSidebarAccordions() {
    // Inline SVG icon set — monochrome outline, 24×24 viewBox, Tabler/Feather style
    var NAV_ICONS = {
        home:           '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="3" y="15" width="7" height="6" rx="1"/><rect x="13" y="3" width="8" height="5" rx="1"/><rect x="13" y="11" width="8" height="10" rx="1"/></svg>',
        sales:          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16l-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5-2 1.5Z"/><path d="M9 7h6M9 11h6M9 15h4"/></svg>',
        products:       '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 6h7l5 6-5 6H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z"/><circle cx="8.5" cy="12" r="1" fill="currentColor"/></svg>',
        customers:      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="7" r="3"/><path d="M3 21v-1a6 6 0 0 1 12 0v1"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/><path d="M21 21v-1a4 4 0 0 0-4-4"/></svg>',
        analytics:      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="13" width="4" height="8" rx="1"/><rect x="10" y="8" width="4" height="13" rx="1"/><rect x="17" y="4" width="4" height="17" rx="1"/><path d="M3 21h18"/></svg>',
        finance:        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z"/><path d="M3 11h18"/><circle cx="17.5" cy="15" r="1.5" fill="currentColor"/></svg>',
        administration: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3L4 6v5c0 4.8 3.6 8.7 8 10 4.4-1.3 8-5.2 8-10V6Z"/><rect x="9" y="11" width="6" height="5" rx="1"/><path d="M10 11V9a2 2 0 1 0 4 0v2"/></svg>',
        settings:       '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z"/></svg>',
    };

    const nav = document.querySelector('#sidebar .sidebar-nav');
    if (!nav || nav.dataset.accordionReady === '1') return;
    nav.dataset.accordionReady = '1';

    const homeLink = nav.querySelector('.sidebar-item[href="/"]');
    if (homeLink) {
        homeLink.classList.add('sidebar-single-tab');
        var homeIconEl = homeLink.querySelector('.sidebar-icon');
        if (homeIconEl && NAV_ICONS.home) homeIconEl.innerHTML = NAV_ICONS.home;
        const next = homeLink.nextElementSibling;
        if (next && next.classList && next.classList.contains('sidebar-divider')) {
            next.classList.add('sidebar-divider-after-single-tab');
        }
        
        // Expand sidebar when dashboard is clicked while collapsed
        homeLink.addEventListener('click', function(e) {
            const sidebar = document.getElementById('sidebar');
            const mainWrapper = document.getElementById('main-wrapper');
            if (sidebar && sidebar.classList.contains('collapsed')) {
                e.preventDefault();
                sidebar.classList.remove('collapsed');
                if (mainWrapper) mainWrapper.classList.remove('sidebar-collapsed');
                try { localStorage.setItem('sidebar_collapsed', '0'); } catch(ex) {}
                setTimeout(() => {
                    window.location.href = homeLink.getAttribute('href');
                }, 100);
            }
        });
    }

    const storageKey = 'sidebar_group_state_v1';
    let stored = {};
    try {
        const raw = localStorage.getItem(storageKey);
        if (raw) stored = JSON.parse(raw) || {};
    } catch (e) {
        stored = {};
    }

    function normalizePath(path) {
        if (!path) return '/';
        const clean = path.split('?')[0].split('#')[0];
        if (clean.length > 1 && clean.endsWith('/')) return clean.slice(0, -1);
        return clean || '/';
    }

    function saveState(key, isOpen) {
        stored[key] = !!isOpen;
        try {
            localStorage.setItem(storageKey, JSON.stringify(stored));
        } catch (e) {}
    }

    function syncChildVisibility(li, link) {
        const isHidden = link.style.display === 'none' || link.hidden || link.getAttribute('aria-hidden') === 'true';
        li.style.display = isHidden ? 'none' : '';
    }

    function getCurrentLocation() {
        return {
            path: normalizePath(window.location.pathname),
            hash: (window.location.hash || '').toLowerCase()
        };
    }

    function getLinkTarget(link) {
        const href = link.getAttribute('href') || '';
        let itemPath = normalizePath(href);
        let itemHash = '';
        try {
            const parsed = new URL(href, window.location.origin);
            itemPath = normalizePath(parsed.pathname);
            itemHash = (parsed.hash || '').toLowerCase();
        } catch (e) {
            const hashIndex = href.indexOf('#');
            if (hashIndex >= 0) itemHash = href.slice(hashIndex).toLowerCase();
        }

        return { itemPath, itemHash };
    }

    function isLinkActive(link) {
        const current = getCurrentLocation();
        const target = getLinkTarget(link);
        const defaultHashByPath = {
            '/settings': '#shop',
            '/reports': '#overview'
        };
        const normalizedCurrentHash = current.hash || (defaultHashByPath[current.path] || '');
        return target.itemHash
            ? (target.itemPath === current.path && target.itemHash === normalizedCurrentHash)
            : (target.itemPath === current.path && !current.hash);
    }

    const allNodes = Array.from(nav.children);
    const grouped = [];

    for (let i = 0; i < allNodes.length; i++) {
        const title = allNodes[i];
        if (!title.classList || !title.classList.contains('sidebar-section-title')) continue;

        const links = [];
        for (let j = i + 1; j < allNodes.length; j++) {
            const next = allNodes[j];
            if (next.classList && next.classList.contains('sidebar-item')) {
                links.push(next);
                continue;
            }
            break;
        }
        if (!links.length) continue;

        const raw = (title.textContent || '').trim();
        const match = raw.match(/^(\S+)\s+(.+)$/);
        const icon = match ? match[1] : '•';
        const label = match ? match[2] : raw;
        const groupKey = 'group_' + label.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');

        const group = document.createElement('div');
        group.className = 'sidebar-group';
        title.classList.forEach((cls) => {
            if (cls !== 'sidebar-section-title') group.classList.add(cls);
        });
        group.dataset.groupKey = groupKey;

        const trigger = document.createElement('button');
        trigger.type = 'button';
        trigger.className = 'sidebar-group-toggle';
        trigger.setAttribute('aria-expanded', 'false');
        var svgIcon = NAV_ICONS[label.toLowerCase()];
        trigger.innerHTML =
            '<span class="sidebar-group-toggle-title">' +
            '<span class="sidebar-group-icon" aria-hidden="true">' + (svgIcon || icon) + '</span>' +
            '<span class="sidebar-group-toggle-label">' + label + '</span>' +
            '</span>' +
            '<span class="sidebar-group-chevron" aria-hidden="true">›</span>';

        const panel = document.createElement('div');
        panel.className = 'sidebar-group-panel';

        const list = document.createElement('ul');
        list.className = 'sidebar-group-list';

        let groupLinks = links;
        if (label.toLowerCase() === 'settings') {
            const kept = [];
            links.forEach((link) => {
                const href = link.getAttribute('href') || '';
                const base = href.split('?')[0].split('#')[0];
                if (base === '/settings' && !href.includes('#')) {
                    link.remove();
                    return;
                }
                if (base === '/shops') {
                    link.remove();
                    return;
                }
                kept.push(link);
            });

            const hasHashSubtabs = kept.some((link) => (link.getAttribute('href') || '').startsWith('/settings#'));
            if (!hasHashSubtabs) {
                const settingsSubtabs = [
                    ['shop', 'Shop'],
                    ['inventory', 'Inventory'],
                    ['notifications', 'Notifications'],
                    ['security', 'Security'],
                    ['backup', 'Backup & Restore']
                ];

                settingsSubtabs.forEach(([key, text]) => {
                    const link = document.createElement('a');
                    link.href = '/settings#' + key;
                    link.className = 'sidebar-item admin-only';
                    link.innerHTML = '<span class="sidebar-label">' + text + '</span>';
                    kept.push(link);
                });
            }

            groupLinks = kept;
        }

        if (label.toLowerCase() === 'analytics') {
            const kept = [];
            links.forEach((link) => {
                const href = link.getAttribute('href') || '';
                const base = href.split('?')[0].split('#')[0];
                if (base === '/reports' && !href.includes('#')) {
                    link.remove();
                    return;
                }
                kept.push(link);
            });

            const hasHashSubtabs = kept.some((link) => (link.getAttribute('href') || '').startsWith('/reports#'));
            if (!hasHashSubtabs) {
                const reportSubtabs = [
                    ['overview', 'Overview', ''],
                    ['sales', 'Sales', ''],
                    ['inventory', 'Inventory', ''],
                    ['customers', 'Customers', ''],
                    ['finance', 'Finance', 'admin-only']
                ];

                reportSubtabs.forEach(([key, text, extraClass]) => {
                    const link = document.createElement('a');
                    link.href = '/reports#' + key;
                    link.className = ('sidebar-item ' + extraClass).trim();
                    link.innerHTML = '<span class="sidebar-label">' + text + '</span>';
                    kept.push(link);
                });
            }

            groupLinks = kept;
        }

        let hasActiveChild = false;
        groupLinks.forEach((link) => {
            link.classList.add('sidebar-group-child');
            if (isLinkActive(link) || link.classList.contains('active')) {
                link.classList.add('active');
                hasActiveChild = true;
            }
            
            // Expand sidebar when group item is clicked while collapsed
            link.addEventListener('click', function(e) {
                const sidebar = document.getElementById('sidebar');
                const mainWrapper = document.getElementById('main-wrapper');
                if (sidebar && sidebar.classList.contains('collapsed')) {
                    e.preventDefault();
                    sidebar.classList.remove('collapsed');
                    if (mainWrapper) mainWrapper.classList.remove('sidebar-collapsed');
                    try { localStorage.setItem('sidebar_collapsed', '0'); } catch(ex) {}
                    setTimeout(() => {
                        window.location.href = link.getAttribute('href');
                    }, 100);
                }
            });
            
            const li = document.createElement('li');
            li.appendChild(link);
            syncChildVisibility(li, link);

            const observer = new MutationObserver(() => {
                syncChildVisibility(li, link);
            });
            observer.observe(link, { attributes: true, attributeFilter: ['style', 'hidden', 'aria-hidden'] });

            list.appendChild(li);
        });

        panel.appendChild(list);
        group.appendChild(trigger);
        group.appendChild(panel);
        nav.insertBefore(group, title);
        title.remove();

        grouped.push({ group, trigger, panel, hasActiveChild, groupKey, groupLabel: label.toLowerCase(), links: groupLinks });
    }

    const financeIndex = grouped.findIndex((item) => item.groupLabel === 'finance');
    const administrationIndex = grouped.findIndex((item) => item.groupLabel === 'administration');
    if (financeIndex !== -1 && administrationIndex !== -1 && financeIndex !== administrationIndex - 1) {
        const administrationItem = grouped[administrationIndex];
        const financeItem = grouped[financeIndex];

        // Capture the divider immediately before Administration (will be orphaned after the move)
        const dividerBeforeAdmin = administrationItem.group.previousElementSibling;
        const hasDividerBefore = dividerBeforeAdmin && dividerBeforeAdmin.classList.contains('sidebar-divider');

        // Move Administration group to after Finance
        nav.insertBefore(administrationItem.group, financeItem.group.nextSibling);

        // Move its divider along with it (inserts a separator before Administration in its new spot)
        if (hasDividerBefore) {
            nav.insertBefore(dividerBeforeAdmin, administrationItem.group);
        } else {
            const sep = document.createElement('div');
            sep.className = 'sidebar-divider admin-only';
            nav.insertBefore(sep, administrationItem.group);
        }

        grouped.splice(administrationIndex, 1);
        const newFinanceIndex = grouped.findIndex((item) => item.groupLabel === 'finance');
        grouped.splice(newFinanceIndex + 1, 0, administrationItem);
    }

    function setOpen(item, open, save) {
        item.group.classList.toggle('is-open', open);
        item.trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
        item.panel.style.maxHeight = open ? item.panel.scrollHeight + 'px' : '0px';
        if (save) saveState(item.groupKey, open);
    }

    function refreshSidebarActiveStates() {
        nav.querySelectorAll('.sidebar-item').forEach((link) => {
            link.classList.remove('active');
        });

        nav.querySelectorAll('.sidebar-item:not(.sidebar-group-child)').forEach((link) => {
            if (isLinkActive(link)) link.classList.add('active');
        });

        grouped.forEach((item) => {
            const hasActiveLink = item.links.some((link) => {
                const active = isLinkActive(link);
                if (active) link.classList.add('active');
                return active;
            });
            item.hasActiveChild = hasActiveLink;
            item.group.classList.toggle('has-active', hasActiveLink);
        });
    }

    grouped.forEach((item) => {
        // Only auto-open the group that contains the current page.
        // Ignore localStorage so navigating away always collapses unrelated groups.
        const startOpen = item.hasActiveChild;
        if (item.hasActiveChild) item.group.classList.add('has-active');
        setOpen(item, startOpen, false);

        item.trigger.addEventListener('click', () => {
            const sidebar = document.getElementById('sidebar');
            const mainWrapper = document.getElementById('main-wrapper');
            
            // If sidebar is collapsed, expand it first
            if (sidebar && sidebar.classList.contains('collapsed')) {
                sidebar.classList.remove('collapsed');
                if (mainWrapper) mainWrapper.classList.remove('sidebar-collapsed');
                try { localStorage.setItem('sidebar_collapsed', '0'); } catch(e) {}
            }
            
            const currentlyOpen = item.trigger.getAttribute('aria-expanded') === 'true';
            if (currentlyOpen) {
                setOpen(item, false, true);
                return;
            }

            grouped.forEach((other) => {
                if (other !== item) setOpen(other, false, true);
            });
            setOpen(item, true, true);
        });
    });

    window.addEventListener('resize', () => {
        grouped.forEach((item) => {
            if (item.trigger.getAttribute('aria-expanded') === 'true') {
                item.panel.style.maxHeight = item.panel.scrollHeight + 'px';
            }
        });
    });

    window.addEventListener('hashchange', refreshSidebarActiveStates);
    refreshSidebarActiveStates();
}

// Restore sidebar state on page load
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const mainWrapper = document.getElementById('main-wrapper');
    if (!sidebar) return;
    if (window.innerWidth > 900) {
        try {
            if (localStorage.getItem('sidebar_collapsed') === '1') {
                sidebar.classList.add('collapsed');
                if (mainWrapper) mainWrapper.classList.add('sidebar-collapsed');
            }
        } catch(e) {}
    }

    initSidebarAccordions();
    bindMobileSidebarLinkClose();
});

// Close any active modal when clicking the backdrop (outside modal-content)
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal') && e.target.classList.contains('active')) {
        e.target.classList.remove('active');
    }
});

// ===== Role helpers =====
/** Check if a role has admin-level permissions (admin, shop_owner, super_admin) */
function isAdminRole(role) {
    return role === 'admin' || role === 'super_admin' || role === 'shop_owner';
}

/** Check if a role can see the shop switcher (shop_owner, super_admin) */
function isMultiShopRole(role) {
    return role === 'super_admin' || role === 'shop_owner';
}

/** Get display label for a role */
function getRoleLabel(role) {
    if (role === 'super_admin') return 'Super Admin';
    if (role === 'shop_owner') return 'Shop Owner';
    if (role === 'admin') return 'Administrator';
    return 'Sales Staff';
}

/** Get role badge CSS class */
function getRoleBadgeClass(role) {
    if (role === 'super_admin') return 'role-badge super-admin';
    if (role === 'shop_owner') return 'role-badge shop-owner';
    if (role === 'admin') return 'role-badge admin';
    return 'role-badge user';
}
