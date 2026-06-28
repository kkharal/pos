// ===== UTC Date Helper =====
// Server always returns UTC datetimes. Append 'Z' so JS treats them as UTC.
function parseUTC(dtStr) {
    if (!dtStr) return null;
    // Already has timezone info
    if (dtStr.endsWith('Z') || /[+-]\d{2}:\d{2}$/.test(dtStr)) return new Date(dtStr);
    // Bare datetime from MySQL — treat as UTC
    return new Date(dtStr.replace(' ', 'T') + 'Z');
}

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
    const nav = document.querySelector('#sidebar .sidebar-nav');
    if (!nav || nav.dataset.accordionReady === '1') return;
    nav.dataset.accordionReady = '1';

    const homeLink = nav.querySelector('.sidebar-item[href="/"]');
    if (homeLink) {
        homeLink.classList.add('sidebar-single-tab');
        const next = homeLink.nextElementSibling;
        if (next && next.classList && next.classList.contains('sidebar-divider')) {
            next.classList.add('sidebar-divider-after-single-tab');
        }
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
        trigger.innerHTML =
            '<span class="sidebar-group-toggle-title">' +
            '<span class="sidebar-group-icon" aria-hidden="true">' + icon + '</span>' +
            '<span class="sidebar-group-toggle-label">' + label + '</span>' +
            '</span>' +
            '<span class="sidebar-group-chevron" aria-hidden="true">▸</span>';

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
        nav.insertBefore(administrationItem.group, financeItem.group.nextSibling);

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
        const hasPersisted = Object.prototype.hasOwnProperty.call(stored, item.groupKey);
        const persisted = hasPersisted ? !!stored[item.groupKey] : false;
        const startOpen = hasPersisted ? persisted : item.hasActiveChild;
        if (item.hasActiveChild) item.group.classList.add('has-active');
        setOpen(item, startOpen, false);

        item.trigger.addEventListener('click', () => {
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
