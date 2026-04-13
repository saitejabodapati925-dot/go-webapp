const savedCoursesKey = "stackpilot-saved-courses";

document.addEventListener("DOMContentLoaded", () => {
    setupNavigation();
    setupRevealAnimations();
    setupCounters();
    setupCourseDashboard();
    setupCourseSaving();
    setupDemoForms();
    setupFooterYear();
});

function setupNavigation() {
    const toggle = document.querySelector("[data-nav-toggle]");
    const page = document.body.dataset.page;

    document.querySelectorAll("[data-nav-link]").forEach((link) => {
        if (link.dataset.navLink === page) {
            link.classList.add("is-active");
        }
    });

    if (!toggle) {
        return;
    }

    toggle.addEventListener("click", () => {
        document.body.classList.toggle("nav-open");
    });

    document.querySelectorAll(".nav-links a").forEach((link) => {
        link.addEventListener("click", () => {
            document.body.classList.remove("nav-open");
        });
    });
}

function setupRevealAnimations() {
    const elements = document.querySelectorAll(".reveal");

    if (!elements.length) {
        return;
    }

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                entry.target.classList.add("is-visible");
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.16 });

    elements.forEach((element) => observer.observe(element));
}

function setupCounters() {
    const counters = document.querySelectorAll("[data-count]");

    if (!counters.length) {
        return;
    }

    const animateCounter = (counter) => {
        const target = Number(counter.dataset.count);
        let current = 0;
        const increment = Math.max(1, Math.ceil(target / 30));

        const tick = () => {
            current = Math.min(target, current + increment);
            counter.textContent = current;
            if (current < target) {
                window.requestAnimationFrame(tick);
            }
        };

        tick();
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach((counter) => observer.observe(counter));
}

function setupCourseDashboard() {
    const dashboard = document.querySelector("[data-course-dashboard]");
    if (!dashboard) {
        return;
    }

    const search = dashboard.querySelector("[data-course-search]");
    const level = dashboard.querySelector("[data-course-level]");
    const topicButtons = dashboard.querySelectorAll("[data-topic-filter]");
    const savedToggle = dashboard.querySelector("[data-saved-toggle]");
    const clearButton = dashboard.querySelector("[data-clear-filters]");
    const results = dashboard.querySelector("[data-course-results]");
    const cards = dashboard.querySelectorAll("[data-course-card]");
    const savedCount = document.querySelector("[data-saved-count]");

    let activeTopic = "all";
    let savedOnly = false;

    const updateResults = () => {
        const query = search.value.trim().toLowerCase();
        const levelValue = level.value;
        const savedCourses = getSavedCourses();
        let visibleCount = 0;

        cards.forEach((card) => {
            const text = card.textContent.toLowerCase();
            const cardTopic = card.dataset.topic;
            const cardLevel = card.dataset.level;
            const isSaved = savedCourses.has(card.dataset.courseId);

            const matchesQuery = !query || text.includes(query);
            const matchesLevel = levelValue === "all" || cardLevel === levelValue;
            const matchesTopic = activeTopic === "all" || cardTopic === activeTopic;
            const matchesSaved = !savedOnly || isSaved;
            const shouldShow = matchesQuery && matchesLevel && matchesTopic && matchesSaved;

            card.hidden = !shouldShow;

            if (shouldShow) {
                visibleCount += 1;
            }
        });

        results.textContent = `Showing ${visibleCount} of ${cards.length} courses`;

        if (savedCount) {
            savedCount.textContent = savedCourses.size;
        }

        if (savedToggle) {
            savedToggle.classList.toggle("is-active", savedOnly);
        }
    };

    topicButtons.forEach((button) => {
        button.addEventListener("click", () => {
            activeTopic = button.dataset.topicFilter;
            topicButtons.forEach((chip) => chip.classList.remove("is-active"));
            button.classList.add("is-active");
            updateResults();
        });
    });

    savedToggle?.addEventListener("click", () => {
        savedOnly = !savedOnly;
        updateResults();
    });

    clearButton?.addEventListener("click", () => {
        search.value = "";
        level.value = "all";
        savedOnly = false;
        activeTopic = "all";
        topicButtons.forEach((button) => {
            button.classList.toggle("is-active", button.dataset.topicFilter === "all");
        });
        updateResults();
    });

    search?.addEventListener("input", updateResults);
    level?.addEventListener("change", updateResults);

    window.addEventListener("savedcourseschange", updateResults);
    window.addEventListener("storage", updateResults);

    updateResults();
}

function setupCourseSaving() {
    const buttons = document.querySelectorAll("[data-save-course]");
    if (!buttons.length) {
        return;
    }

    const syncButtons = () => {
        const savedCourses = getSavedCourses();
        const savedCount = document.querySelector("[data-saved-count]");

        buttons.forEach((button) => {
            const card = button.closest("[data-course-card]");
            const isSaved = card ? savedCourses.has(card.dataset.courseId) : false;
            button.classList.toggle("is-saved", isSaved);
            button.textContent = isSaved ? "Saved" : "Save";
        });

        if (savedCount) {
            savedCount.textContent = savedCourses.size;
        }
    };

    buttons.forEach((button) => {
        button.addEventListener("click", () => {
            const card = button.closest("[data-course-card]");
            if (!card) {
                return;
            }

            const savedCourses = getSavedCourses();
            const courseId = card.dataset.courseId;

            if (savedCourses.has(courseId)) {
                savedCourses.delete(courseId);
            } else {
                savedCourses.add(courseId);
            }

            setSavedCourses(savedCourses);
            syncButtons();
            window.dispatchEvent(new Event("savedcourseschange"));
        });
    });

    syncButtons();
}

function setupDemoForms() {
    const forms = document.querySelectorAll("[data-demo-form]");

    forms.forEach((form) => {
        form.addEventListener("submit", (event) => {
            event.preventDefault();

            if (!form.reportValidity()) {
                return;
            }

            const status = form.querySelector("[data-form-status]");
            const formName = form.dataset.demoForm;

            if (status) {
                status.textContent = formName === "contact"
                    ? "Message captured on the front end. Connect this form to a backend endpoint when you are ready."
                    : "You are subscribed to the weekly build note demo flow.";
            }

            form.reset();
        });
    });
}

function setupFooterYear() {
    document.querySelectorAll("[data-current-year]").forEach((element) => {
        element.textContent = new Date().getFullYear();
    });
}

function getSavedCourses() {
    try {
        const raw = window.localStorage.getItem(savedCoursesKey);
        return new Set(raw ? JSON.parse(raw) : []);
    } catch (error) {
        return new Set();
    }
}

function setSavedCourses(savedCourses) {
    window.localStorage.setItem(savedCoursesKey, JSON.stringify(Array.from(savedCourses)));
}
