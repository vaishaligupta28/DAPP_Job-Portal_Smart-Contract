import React, { useEffect, useRef, useState } from "react";
import styles from "./home.module.css";
import { useAppContext } from "../contexts/AppContext";
import toast from "react-hot-toast";

const Home = () => {
  const { web3, account, connectToMetaMask, connected, connecting } =
    useAppContext();
  const inputRef = useRef(null);

  const [isLoading, setIsLoading] = useState("idle");
  const [number, setNumber] = useState("");

  const getNumber = async (e) => {
    try {
      setIsLoading("fetching");
      const number = await web3.methods.getData().call();
      setIsLoading("idle");
      setNumber(number);
    } catch (error) {
      setIsLoading("idle");
      toast.error("Error in fetching fleet");
    }
  };

  const handleAddNumber = async (e) => {
    e.preventDefault();
    if (inputRef.current.value === "") {
      return;
    }

    try {
      setIsLoading("adding");
      if (!account) {
        toast.error("Please connect to your wallet");
        setIsLoading("idle");
        return;
      }

      await web3.methods
        .setData(inputRef.current.value)
        .send({
          from: account,
          gas: 3000000,
        })
        .on("receipt", () => {
          inputRef.current.value = "";
          getNumber();
          toast.success("Number added successfully");
          setIsLoading("idle");
        })
        .on("error", () => {
          throw new Error("Error in adding number");
        });
    } catch (error) {
      console.log(error);
      toast.error("Error in adding number");
      setIsLoading("idle");
    }
  };

  useEffect(() => {
    if (connected) {
      getNumber();
    }
  }, [connected]);

  return (
    <section className={styles.home}>
      <div className={styles.wallet}>
        {!connected && (
          <button onClick={connectToMetaMask}>
            {connecting ? "Connecting..." : "Connect to MetaMask"}
          </button>
        )}
      </div>
      <div className={styles.number}>
        {isLoading === "fetching" ? (
          <p>Fetching number...</p>
        ) : (
          <p>
            Number: <span>{number.toString()}</span>
          </p>
        )}
      </div>
      <div className={styles.form}>
        <form onSubmit={handleAddNumber}>
          <input
            type="number"
            placeholder="Enter number"
            ref={inputRef}
            disabled={!connected}
          />
          <button type="submit" disabled={!connected || isLoading === "adding"}>
            {isLoading === "adding" ? "Adding..." : "Add Number"}
          </button>
        </form>
      </div>
    </section>
  );
};

export default Home;
