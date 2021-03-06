import DOM from "./dom";
import { LitElement, html, customElement, property } from "lit-element";
import { staticPages } from "./routes";
import React from "react";
import ReactDOM from "react-dom";
@customElement("page-loader")
export default class PageLoader extends LitElement {
  @property()
  name;
  @property()
  route;

  createRenderRoot() {
    return this;
  }

  constructor(args) {
    super(args);
    window.addEventListener("popstate", (e) => {
      this.load(location.pathname, staticPages);
    });
  }

  pageContent = null;

  render() {
    return html`
      <div class="xl:col-start-2 xl:col-span-2 lg:col-start-1">
        <main id="content" class="p-5">${this.pageContent}</main>
      </div>
    `;
  }

  async load(page, pages) {
    pages = pages || staticPages;
    let pageItem = pages.find((item) => item.route === page);
    if (!pageItem) {
      console.log('No find?', page);
      return;
    }

    if (location.pathname !== pageItem.route && location.pathname !== "/") {
      window.history.pushState(null, pageItem.title, pageItem.route);
    }

    if (pageItem == null) {
      let pageName = location.href.split("/").pop();
      if (pageName !== "") {
        pageItem = pages.find((x) => x.name == pageName);
      } else {
        pageItem = pages[0];
      }
    }

    this.classList.add("relative", "grid", "xl:grid-cols-4", "lg:grid-cols-1");
    this.setAttribute("style", "top: 70px");

    try {
      let pagePrefix = pageItem.name.substr(0, pageItem.name.indexOf("-") + 1);
      let modulePage = pageItem.name.replace(pagePrefix, ""); // Removes the module source
      let suffix = "-page";
      if (modulePage === "dapp") {
        await import(`../pages/${modulePage}.js`);
      } else if (pageItem.name.includes(suffix)) {
        const LoadedComponent = await import(`../pages/${pageItem.name}`);
        let element;
        ReactDOM.render(
          React.createElement(LoadedComponent.default),
          document.getElementById("content")
        );
        this.requestUpdate();
        return;
      } else if (pagePrefix === "dapp") {
        await import(`../pages/${modulePage}.js`);
      } else if (modulePage === "harness") {
        await import(`../harness/harness.js`);
      } else if (modulePage === "customizer") {
        await import(`./customizer.js`);
      } else if (modulePage.indexOf("-customizer") > -1) {
        // Dynamically added
        await import(`../harness/${modulePage}.js`);
        suffix = "";
      } else {
        suffix = "-harness";
        await import(`../harness/${modulePage}-harness.js`);
      }
      let pageName = modulePage.replace("_", "-") + suffix;
      this.pageContent = DOM.create(pageName, {
        title: pageItem.title,
        description: pageItem.description,
        category: pageItem.category,
      });
    } catch (e) {
      console.log(e);
      this.pageContent = DOM.div(
        `Error loading content page for "${pageItem.title}"`
      );
    }
    this.requestUpdate();
  }
}
