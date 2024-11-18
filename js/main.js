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
