const sections = [...document.querySelectorAll("main section[id], footer[id]")];
const navLinks = [...document.querySelectorAll(".nav a")];
const revealTargets = [...document.querySelectorAll(".reveal")];

const activeByHash = (hash) => {
  navLinks.forEach((link) => {
    link.classList.toggle("is-active", link.getAttribute("href") === hash);
  });
};

const sectionObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        activeByHash(`#${entry.target.id}`);
      }
    });
  },
  {
    threshold: 0.35,
    rootMargin: "-10% 0px -35% 0px",
  }
);

sections.forEach((section) => sectionObserver.observe(section));

const revealObserver = new IntersectionObserver(
  (entries, observer) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) {
        return;
      }

      entry.target.classList.add("is-visible");
      observer.unobserve(entry.target);
    });
  },
  { threshold: 0.14 }
);

revealTargets.forEach((target) => revealObserver.observe(target));

if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  revealTargets.forEach((target) => target.classList.add("is-visible"));
}

if (window.location.hash) {
  activeByHash(window.location.hash);
}
