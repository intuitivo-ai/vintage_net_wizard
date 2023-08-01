defmodule VintageNetWizard.CameraToHls do
    @moduledoc """
    This is an entry module for the demo
    which starts the CameraToHls Pipeline
    """
  
    use Application
    alias VintageNetWizard.Pipeline
  
    def start(_type, _args) do
      {:ok, _pipeline_supervisor, pipeline} = Pipeline.start_link()
      send(pipeline, :play)
      
      {:ok, pipeline}
    end
  end