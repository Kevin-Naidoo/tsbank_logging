# BankAccount Module
defmodule BankAccount do
  require Logger
  use GenServer
  alias Transaction
  alias BankRegistry
  alias Odna.LogHelpers

  # Starts the GenServer for a BankAccount
  @spec start_link(any(), number()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(account_number, initial_balance) when is_number(initial_balance) and initial_balance >= 0 do
    result = GenServer.start_link(__MODULE__, initial_balance, name: {:via, Registry, {BankRegistry, account_number}})
    LogHelpers.logify("Bank Account", [account_number, initial_balance], "New Account for #{account_number} with amount #{initial_balance}", :business)
    LogHelpers.logify("BankAccount.startlink()", [account_number, initial_balance], "Successfully started BankAccount Genserver for account: #{account_number} with amount: #{initial_balance}")
    Logger.info("Bank Account started")
    result  # Return the result of GenServer.start_link
  end

  # Deposit function
  def deposit(pid, amount) do
    try do
      case GenServer.call(pid, {:deposit, amount}) do
        {:ok, new_balance} ->
          Logger.debug("Deposited #{amount}. New balance: #{new_balance}")
        {:ok, new_balance}

        {:error, reason} ->
          Logger.error("Deposit failed: #{reason}")
        {:error, reason}
      end
    rescue
      _ -> {:error, "Invalid PID"}
    end
  end


  # Withdraw function
  def withdraw(pid, amount) do
    try do
      case GenServer.call(pid, {:withdraw, amount}) do
        {:ok, new_balance} ->
          Logger.debug("Withdrew #{amount}. New balance: #{new_balance}")
          LogHelpers.logify("BankAccount.withdraw", [amount: amount, balance: new_balance], "Withdrew #{amount}. New balance: #{new_balance}")
          {:ok, new_balance}
        {:error, reason} ->
          Logger.error("Withdrawal failed: #{reason}")
          LogHelpers.handle_err_fb("BankAccount.withdraw", [amount: amount], :insufficient_funds, "Withdrawal failed", {:error, "Insufficient Funds"})
          {:error, reason}
          #handle_err_fb("AdditionApp.add", [a, b], :bad_request, "Failed to add numbers", {:error, "Unknown error"})
      end
    rescue
      _ -> {:error, "Invalid PID"}
    end
  end

# Balance function
def balance(pid) do
  try do
    GenServer.call(pid, :balance)
  rescue
    _ -> {:error, "Invalid PID"}
  end
end

  # Transfer function
  def transfer(from_account, to_account, amount) do
    with [{from_account_pid, _}] <- Registry.lookup(BankRegistry, from_account),
          [{to_account_pid, _}] <- Registry.lookup(BankRegistry, to_account),
          {:ok, _} <- GenServer.call(from_account_pid, {:withdraw, amount}) do
      Logger.debug("Both accounts exist and withdrawal was successful.")

      case GenServer.call(to_account_pid, {:deposit, amount}) do
        {:ok, _} -> Logger.debug("Transfer was successful.")
          {:ok, "Transfer successful"}

        {:error, reason} -> Logger.error("Deposit failed: #{reason}")
          {:error, reason}
      end
    else
      _ -> {:error, "Transfer failed. Either one of the accounts does not exist, or withdrawal failed."}
    end
  end

  # GenServer Callbacks

  def handle_call({:deposit, amount}, _from, balance) when amount > 0 do
    new_balance = balance + amount
    Logger.debug("Deposited #{amount}. New balance: #{new_balance}")
    {:reply, {:ok, new_balance}, new_balance}
  end

  def handle_call({:deposit, amount}, _from, balance) when amount <= 0 do
    {:reply, {:error, "Invalid amount"}, balance}
  end

  def handle_call({:withdraw, amount}, _from, balance) when amount > 0 and amount <= balance do
    new_balance = balance - amount
    Logger.debug("Withdrew #{amount}. New balance: #{new_balance}")
    {:reply, {:ok, new_balance}, new_balance}
  end

  def handle_call({:withdraw, _amount}, _from, balance) do
    #Logger.warning("Attempt to withdraw with insufficient funds.")
    {:reply, {:error, "Insufficient funds"}, balance}
  end

  def handle_call(:balance, _from, balance) do
    Logger.info("Balance checked. Current balance: #{balance}")
    {:reply, balance, balance}
  end

  # Initialization callback
  def init(initial_balance) do
    {:ok, initial_balance}
  end

end
