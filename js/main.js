// For dictionary page, handle the interaction to show and hide the corresponding content when a letter is clicked
document.addEventListener("DOMContentLoaded", () => {
    const letters = document.querySelectorAll(".letter");
    const contents = document.querySelectorAll(".content");

    // Default to "A"
    letters[0].classList.add("active");
    document.querySelector("#A").classList.add("active");

    letters.forEach((letter) => {
        letter.addEventListener("click", (e) => {
            e.preventDefault();

            // Remove active class from all letters and contents
            letters.forEach((l) => l.classList.remove("active"));
            contents.forEach((content) => content.classList.remove("active"));

            // Add active class to the clicked letter and the corresponding content
            letter.classList.add("active");
            const letterContent = document.querySelector(`#${letter.dataset.letter}`);
            if (letterContent) {
                letterContent.classList.add("active");
            }
        });
    });
});

document.addEventListener("DOMContentLoaded", () => {
    const buttons = document.querySelectorAll("#alphabet-nav button");
    const sections = document.querySelectorAll(".category-section");

    function showSection(letter) {
        sections.forEach(section => {
            section.classList.toggle("active", section.id === `section-${letter}`);
        });
    }

    buttons.forEach(button => {
        button.addEventListener("click", () => {
            showSection(button.dataset.letter);
        });
    });

    // Show default section (A)
    showSection("A");
});
