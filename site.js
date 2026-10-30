// Renders the gallery and the guest stars from photos.json, so adding a photo
// never means editing HTML. Text goes in with textContent, never as HTML,
// because guest entries come from outside contributors.
(async function () {
  let data;
  try {
    data = await (await fetch("photos.json")).json();
  } catch (err) {
    console.error("could not load photos.json", err);
    return;
  }

  // A <picture> that offers the modern format crustyimg picked (usually
  // AVIF) and falls back to the JPEG the build always writes alongside it.
  function picture(entry, dir) {
    const base = "assets/photos/" + dir;
    const pic = document.createElement("picture");
    if (entry.modern) {
      const source = document.createElement("source");
      source.srcset = base + entry.modern;
      source.type = "image/" + entry.modern.split(".").pop();
      pic.append(source);
    }
    const img = document.createElement("img");
    img.src = base + entry.file.replace(/\.[^.]+$/, ".jpg");
    img.alt = entry.alt || "";
    if (entry.position) img.style.objectPosition = entry.position;
    pic.append(img);
    return pic;
  }

  function figure(entry, dir) {
    const fig = document.createElement("figure");
    const pic = picture(entry, dir);
    pic.querySelector("img").loading = "lazy";
    const cap = document.createElement("figcaption");
    cap.textContent = entry.caption || "";
    fig.append(pic, cap);
    return fig;
  }

  // The hero is in the HTML so it shows before this script runs; swap in
  // the modern format once we know its name.
  const heroImg = document.querySelector(".hero__photo img");
  if (data.hero && data.hero.modern && heroImg) {
    const pic = picture(data.hero, "");
    pic.querySelector("img").width = heroImg.width;
    heroImg.replaceWith(pic);
  }

  const gallery = document.getElementById("gallery");
  for (const entry of data.gallery || []) gallery.append(figure(entry, ""));

  const guests = data.guests || [];
  const guestGrid = document.getElementById("guest-gallery");
  for (const entry of guests) {
    const fig = figure(entry, "guests/");
    const credit = document.createElement("span");
    credit.className = "credit";
    credit.append(entry.cat ? entry.cat + " · photo by " : "Photo by ");
    const link = document.createElement("a");
    link.href = "https://github.com/" + encodeURIComponent(entry.credit);
    link.textContent = "@" + entry.credit;
    credit.append(link);
    fig.querySelector("figcaption").append(document.createElement("br"), credit);
    guestGrid.append(fig);
  }
  if (guests.length > 0) document.getElementById("guests-empty").hidden = true;

  // The browser jumps to a #section link before the photos above it exist,
  // so jump again now that the page has its full height.
  if (location.hash) document.getElementById(location.hash.slice(1))?.scrollIntoView();
})();
