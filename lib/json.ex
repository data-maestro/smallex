defmodule Json do
  @moduledoc """
  JSON API call library (with parse support).
  """

  @doc """
  Get JSON API (header & map_function are optional)

  ## Examples
    iex> Json.get( "https://api.github.com", "/rate_limit" )[ "rate" ][ "limit" ]
    60

    iex> Json.get("https://api.github.com/rate_limit")["rate"]["limit"]
    60

    iex> Json.get_raw_response( "https://api.github.com", "/rate_limit" ).status_code
    200
    
    iex> Json.get_raw_response( "https://api.github.com/rate_limit" ).status_code
    200
  """
  def get_raw_response(url), do: get_raw_response(url, "Content-Type": "application/json")

  def get_raw_response(url, header) when is_list(header), do: HTTPoison.get!(url, header)

  def get_raw_response(domain, path),
    do: get_raw_response(domain, path, "Content-Type": "application/json")

  def get_raw_response(domain, path, header) do
    (domain <> path)
    |> get_raw_response(header)
  end

  def get(url), do: get(url, "Content-Type": "application/json")

  def get(url, header) when is_list(header) do
    get_raw_response(url, header)
    |> parse
  end

  def get(domain, path), do: get(domain, path, "Content-Type": "application/json")

  def get(domain, path, header) do
    (domain <> path)
    |> get(header)
  end

  @doc ~S"""
  Post JSON API (header & map_function are optional)

  ## Examples
    iex> Json.post( "https://httpbin.org", "/post?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" )[ "args" ]
    %{"param1" => "value1"}

    iex> Json.post( "https://httpbin.org", "/post?param1=value1", "{\"data1\":\"value1\"}", "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.post( "https://httpbin.org", "/post?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.post( "https://httpbin.org/post?param1=value1", "{\"data1\":\"value1\"}", "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.post( "https://httpbin.org/post?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.post( "https://httpbin.org", "/post?param1=value1", "{ \"data1\":\"value1\" }" )[ "args" ]
    %{"param1" => "value1"}

    iex> Json.post_raw_response( "https://httpbin.org", "/post?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" ).status_code
    200

    iex> Json.post_raw_response( "https://httpbin.org", "/post?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" ).status_code
    200
    
    iex> Json.post_raw_response( "https://httpbin.org/post?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" ).status_code
    200
    
    iex> Json.post_raw_response( "https://httpbin.org/post?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" ).status_code
    200
  """
  def post_raw_response(url, body),
    do: post_raw_response(url, body, "Content-Type": "application/json")

  def post_raw_response(url, body, header) when is_map(body) and is_list(header) do
    {:ok, body} = body |> Jason.encode()
    post_raw_response(url, body, header)
  end

  def post_raw_response(url, body, header) when is_list(header) do
    HTTPoison.post!(url, body, header)
  end

  def post_raw_response(domain, path, body) when is_map(body) do
    {:ok, body} = body |> Jason.encode()

    (domain <> path)
    |> post_raw_response(body, "Content-Type": "application/json")
  end

  def post_raw_response(domain, path, body, header) do
    (domain <> path)
    |> post_raw_response(body, header)
  end

  def post(url, body), do: post(url, body, "Content-Type": "application/json")

  def post(url, body, header) when is_list(header) do
    post_raw_response(url, body, header)
    |> parse
  end

  def post(domain, path, body) do
    (domain <> path)
    |> post(body, "Content-Type": "application/json")
  end

  def post(domain, path, body, header) do
    (domain <> path)
    |> post(body, header)
  end

  @doc ~S"""
  Put JSON API (header & map_function are optional)

  ## Examples
    iex> Json.put( "https://httpbin.org", "/put?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" )[ "args" ]
    %{"param1" => "value1"}

    iex> Json.put( "https://httpbin.org", "/put?param1=value1", "{ \"data1\": \"value1\" }", "Content-Type": "application/json" )[ "json" ]
    %{"data1"=> "value1"}

    iex> Json.put( "https://httpbin.org", "/put?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" )[ "json" ]
    %{"data1"=> "value1"}

    iex> Json.put( "https://httpbin.org/put?param1=value1", "{ \"data1\": \"value1\" }", "Content-Type": "application/json" )[ "json" ]
    %{"data1"=> "value1"}

    iex> Json.put( "https://httpbin.org/put?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" )[ "json" ]
    %{"data1"=> "value1"}

    iex> Json.put_raw_response( "https://httpbin.org", "/put?param1=value1", "{ \"data1\": \"value1\" }", "Content-Type": "application/json" ).status_code
    200

    iex> Json.put_raw_response( "https://httpbin.org", "/put?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" ).status_code
    200

    iex> Json.put_raw_response( "https://httpbin.org/put?param1=value1", "{ \"data1\": \"value1\" }", "Content-Type": "application/json" ).status_code
    200

    iex> Json.put_raw_response( "https://httpbin.org/put?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" ).status_code
    200
  """
  def put_raw_response(url, body),
    do: put_raw_response(url, body, "Content-Type": "application/json")

  def put_raw_response(url, body, header) when is_map(body) and is_list(header) do
    {:ok, body} = body |> Jason.encode()
    put_raw_response(url, body, header)
  end

  def put_raw_response(url, body, header) when is_list(header) do
    HTTPoison.put!(url, body, header)
  end

  def put_raw_response(domain, path, body) when is_map(body) do
    {:ok, body} = body |> Jason.encode()

    (domain <> path)
    |> put_raw_response(body, "Content-Type": "application/json")
  end

  def put_raw_response(domain, path, body, header) do
    (domain <> path)
    |> put_raw_response(body, header)
  end

  def put(url, body), do: put(url, body, "Content-Type": "application/json")

  def put(url, body, header) when is_list(header) do
    put_raw_response(url, body, header)
    |> parse
  end

  def put(domain, path, body) do
    (domain <> path)
    |> put(body, "Content-Type": "application/json")
  end

  def put(domain, path, body, header) do
    (domain <> path)
    |> put(body, header)
  end

  @doc ~S"""
  Patch JSON API (header & map_function are optional)

  ## Examples
    iex> Json.patch( "https://httpbin.org", "/patch?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" )[ "args" ]
    %{"param1" => "value1"}

    iex> Json.patch( "https://httpbin.org", "/patch?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.patch( "https://httpbin.org", "/patch?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" )[ "json" ]
    %{"data1" => "value1"}

    iex> Json.patch_raw_response( "https://httpbin.org", "/patch?param1=value1", "{ \"data1\":\"value1\" }", "Content-Type": "application/json" ).status_code
    200

    iex> Json.patch_raw_response( "https://httpbin.org", "/patch?param1=value1", %{ data1: "value1" }, "Content-Type": "application/json" ).status_code
    200
  """
  def patch_raw_response(url, body), do: patch_raw_response(url, body, "Content-Type": "application/json")

  def patch_raw_response(url, body, header) when is_map(body) and is_list(header) do
    {:ok, body} = body |> Jason.encode()
    patch_raw_response(url, body, header)
  end

  def patch_raw_response(url, body, header) when is_list(header) do
    HTTPoison.patch!(url, body, header)
  end

  def patch_raw_response(domain, path, body) when is_map(body) do
    {:ok, body} = body |> Jason.encode()
    (domain <> path)
    |> patch_raw_response(body, "Content-Type": "application/json")
  end

  def patch_raw_response(domain, path, body, header) do
    (domain <> path)
    |> patch_raw_response(body, header)
  end

  def patch(url, body), do: patch(url, body, "Content-Type": "application/json")

  def patch(url, body, header) when is_list(header) do
    patch_raw_response(url, body, header)
    |> parse
  end

  def patch(domain, path, body) do
    (domain <> path)
    |> patch(body, "Content-Type": "application/json")
  end

  def patch(domain, path, body, header) do
    (domain <> path)
    |> patch(body, header)
  end

  @doc """
  Delete JSON API (header & map_function are optional)

  ## Examples
    iex> ( Json.delete( "https://httpbin.org", "/delete?param1=value1", "Content-Type": "application/json" ) )[ "args" ]
    %{"param1" => "value1"}

    iex> Json.delete_raw_response("https://httpbin.org", "/delete?param1=value1", "Content-Type": "application/json" ).status_code
    200
  """
  def delete_raw_response(domain, path, header \\ ["Content-Type": "application/json"]) do
    (domain <> path)
    |> HTTPoison.delete!(header)
  end

  def delete(domain, path, header \\ ["Content-Type": "application/json"]) do
    delete_raw_response(domain, path, header)
    |> parse
  end

  @doc """
  Head JSON API (header & map_function are optional)

  ## Examples
    iex> Json.head( "https://httpbin.org", "/", ["Content-Type": "application/json"] )
    ""
  """
  def head(domain, path, header \\ ["Content-Type": "application/json"]) do
    (domain <> path)
    |> HTTPoison.head!(header)
    |> get_body
  end

  defp parse(response) do
    response
    |> get_body
    |> Jason.decode!()
  end

  defp get_body(%{status_code: 200, body: body}), do: body
  defp get_body(%{status_code: 201, body: body}), do: body
  defp get_body(%{status_code: 204, body: body}), do: body
end
