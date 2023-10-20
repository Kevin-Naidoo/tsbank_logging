defmodule Odna.LogHelpers do
  import FC.Error
  @moduledoc """
    Common Logging helpers.  Import the library to easily use them.

    Normal messages will log to the info log by default, pass `:debug` as the first parameter to use
    go into the debug log.
    Error will go into the error log.
  """

  @doc """
    Common logging helper that takes a function header (fh) and various error types to return and log errors.
  """
  def handle_err_fb(fh, params, error_code, error_text, {:error, _error_msg}) do
    logify(fh, params, error_text)
    err = %FC.Error{
      error_text: error_text,
      status: error_code,
      domain: fh,
      description: "[#{error_text}][params: #{inspect params}]"
    }
    #logify(:error,params,fh,err)
    # IO.inspect({:error,err})
  end

  def handle_err_fb(fh, params, error_code, error_text, {reason, {:EXIT, error_msg}}) do
    handle_err_fb(fh, params, error_code, "#{reason}::#{error_text}", {:error, error_msg})
  end

  def handle_err_fb(fh, params, error_code, error_text, {reason, error_msg}) do
    handle_err_fb(fh, params, error_code, "#{reason}::#{error_text}", {:error, inspect(error_msg)})
  end

  def handle_err_fb(fh, params, error_code, _error_text, error) do
    handle_err_fb(fh, params, error_code, "UNKOWN ERROR", {:error, inspect(error)})
  end


  @doc """
    Common logging helper that tales function header (fh) parameter term, and text for logging.
  """
  def logify(fh, params, log_text) do
    :logger.info("~s [ ~s ] [params: ~w]",[fh,log_text,params])
  end

  def logify(:debug, fh, params, log_text) do
    :logger.debug("~s [ ~s ] [params: ~w]",[fh,log_text, params])
  end

  def logify(:error, fh, params, error) do
    :logger.error("~s[~w][~w]",[fh,error,params])
  end
#Logger.info()
  def logify(fh, params, log_text, log_class) do
    :logger.info("~s [ ~s ] [params: ~w][ ~s ]",[fh,log_text,params,log_class])
  end
end
