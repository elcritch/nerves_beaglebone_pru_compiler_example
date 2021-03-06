defmodule NervesBeaglebonePruCompilerExample.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell().info([
    :green,
    """
    Mix environment
      MIX_TARGET:   #{@target}
      MIX_ENV:      #{Mix.env()}
    """,
    :reset
  ])

  def project do
    [
      app: :nerves_beaglebone_pru_compiler_example,
      version: "0.1.0",
      elixir: "~> 1.6",
      target: @target,
      archives: [nerves_bootstrap: "~> 0.6"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      compilers: [:pru_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(@target),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke Blinky.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end

  def application(_target) do
    [mod: {Blinky, []}, extra_applications: [:logger]]
  end

  def deps do
    [{:nerves, "~> 0.7", runtime: false}] ++ deps(@target)
  end

  # Specify target specific dependencies
  def deps("host"), do: []

  def deps(target) do
    IO.puts "deps target"
    [
      system(target),
      {:bootloader, "~> 0.1"},
      {:nerves_runtime, "~> 0.4"},
      {:nerves_leds, "~> 0.7"},
      {:nerves_pru_icss, ">= 0.0.0", github: "elcritch/nerves_pru_icss"},
      {:elixir_ale, "~> 1.0.2"}
    ]
  end

  # Specify the version of the System to use for each target
  def system("bbb"), do: {:nerves_system_bbb, "~> 0.16.0", runtime: false}

  # Remember to run `source nerves_system_bbb_pru/build/nerves-env.sh` when building custom base image!
  def system("bbb_custom") do
    {:nerves_system_bbb_pru,
     branch: "master", git: "https://github.com/elcritch/nerves_system_bbb.git", runtime: false}
  end

  def system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: []

  def aliases(_target) do
    [
      "deps.precompile": ["nerves.precompile", "deps.precompile"],
      "deps.loadpaths": ["deps.loadpaths", "nerves.loadpaths"]
    ]
  end
end
