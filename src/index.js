import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import MetamaskProvider from "./utils/MetamaskProvider";
import { AppContextProvider } from "./contexts/AppContext";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <MetamaskProvider>
      <AppContextProvider>
        <App />
      </AppContextProvider>
    </MetamaskProvider>
  </React.StrictMode>
);
