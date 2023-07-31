defmodule VintageNetWizard.CameraToHls do
    @moduledoc """
    This is an entry module for the demo
    which starts the CameraToHls Pipeline
    """
  
    use Application
    alias Membrane.Demo.CameraToHls.Pipeline
  
    @impl true
    def start(_type, _args) do
      {:ok, pid} = Pipeline.start_link()
      Membrane.Pipeline.play(pid)
  
      {:ok, pid}
    end
  end