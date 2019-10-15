defmodule VintageNetWizard do
  @moduledoc """
  Documentation for VintageNetWizard.
  """

  alias VintageNetWizard.{Backend, Web.Endpoint}

  @doc """
  Run the wizard.

  This means the WiFi module will be put into access point
  mode and the web server will be started.

  Options:

    - `:ssl` - A Keyword list of `:ssl.tls_server_options`

  See `Plug.SSL.configure/1` for more information about the
  SSL options.
  """
  @spec run_wizard([Endpoint.opt()]) :: :ok | {:error, String.t()}
  def run_wizard(opts \\ []) do
    with :ok <- Backend.reset(),
         :ok <- into_ap_mode(),
         {:ok, _server} <- Endpoint.start_server(opts),
         :ok <- Backend.start_scan() do
      :ok
    else
      # Already running is still ok
      {:error, :already_started} -> :ok
      error -> error
    end
  end

  @doc """
  Change the WiFi module into access point mode
  """
  def into_ap_mode() do
    ssid = get_hostname()
    our_ip_address = {192, 168, 0, 1}
    our_name = Application.get_env(:vintage_net_wizard, :dns_name, "wifi.config")

    config = %{
      type: VintageNet.Technology.WiFi,
      wifi: %{
        networks: [
          %{
            mode: :host,
            ssid: ssid,
            key_mgmt: :none
          }
        ]
      },
      ipv4: %{
        method: :static,
        address: our_ip_address,
        prefix_length: 24
      },
      dhcpd: %{
        # These are defaults and are reproduced here as documentation
        start: {192, 168, 0, 20},
        end: {192, 168, 0, 254},
        max_leases: 235,
        options: %{
          dns: [our_ip_address],
          subnet: {255, 255, 255, 0},
          router: [our_ip_address],
          domain: our_name,
          search: [our_name]
        }
      },
      dnsd: %{
        records: [
          {our_name, our_ip_address}
        ]
      }
    }

    VintageNet.configure("wlan0", config, persist: false)
  end

  defdelegate start_server(), to: Endpoint

  defdelegate stop_server(), to: Endpoint

  defp get_hostname() do
    {:ok, hostname} = :inet.gethostname()
    to_string(hostname)
  end
end
