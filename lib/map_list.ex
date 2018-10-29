defmodule MapList do
	@moduledoc """
	Map list library.
	"""

	@doc """
	To CSV (Pickup keys from first line)

	## Examples (Comment out as doctest does not work)
		# iex> MapList.to_csv( [ %{ "c1" => "v1", "c2" => 2, "c3" => true }, %{ "c1" => "v2", "c2" => 5, "c3" => false } ] )
		# "c1, c2, c3\n\"v1\", \"2\", \"true\"\n\"v2\", \"5\", \"false\"\n"
	"""
	def to_csv( map_list, option \\ :quote ) do
		columns = ( map_list |> List.first |> Map.keys |> Lst.to_csv ) <> "\n"
		rows = map_list |> Enum.reduce( "", fn( row, acc ) -> acc <> ( row |> Map.values |> Lst.to_csv( option ) ) <> "\n" end )
		columns <> rows
	end

	@doc """
	Zip columns list(first line) and list of rows list(after second lines)

	## Examples
		iex> MapList.first_columns_after_rows( [ [ "c1", "c2", "c3" ], [ "v1", 2, true ], [ "v2", 5, false ] ] )
		[ %{ "c1" => "v1", "c2" => 2, "c3" => true }, %{ "c1" => "v2", "c2" => 5, "c3" => false } ]
		iex> MapList.first_columns_after_rows( [ [ "c1", "c2", "c3" ], [ "v1", 2, true ], [ "v2", 5, false ] ], :atom )
		[ %{ c1: "v1", c2: 2, c3: true }, %{ c1: "v2", c2: 5, c3: false } ]
	"""
	def first_columns_after_rows( columns_rows, with_atom \\ :no_atom ) do
		columns = columns_rows |> List.first
		rows    = columns_rows |> Enum.drop( 1 )
		Lst.columns_rows( columns, rows, with_atom )
	end

	@doc """
	Outer join keys to map-list on same key-value pair from another

	## Examples
		iex> MapList.merge( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], [ %{ "a" => "key1", "c" => 13 }, %{ "a" => "key3", "c" => 23 } ], "a", "no_match" )
		[ %{ "a" => "key1", "b" => 12, "c" => 13 }, %{ "a" => "key2", "b" => 22, "c" => "no_match" } ]
	"""
	def merge( base_map_list, add_map_list, match_key, no_match_value ) do
		empty_add_map = make_extracted_keys_map_exclude_key( add_map_list, match_key, no_match_value )
		adds = add_map_list |> Enum.map( &( &1[ match_key ] ) )
		match_map_list = base_map_list
			|> Enum.filter( &( adds |> Enum.member?( &1[ match_key ] ) ) )
			|> Enum.map( &( Map.merge( &1, find( add_map_list, &1, match_key ) ) ) )
		nomatch_map_list = no_match_maps( base_map_list, add_map_list, match_key )
			|> Enum.map( &( Map.merge( &1, empty_add_map ) ) )
		match_map_list ++ nomatch_map_list
	end

	@doc """
	Inner join keys to map-list on same key-value pair from another

	## Examples
		iex> MapList.replace( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], [ %{ "a" => "key1", "c" => 13 }, %{ "a" => "key3", "c" => 23 } ], "a" )
		[ %{ "a" => "key1", "b" => 12, "c" => 13 }, %{ "a" => "key2", "b" => 22 } ]
	"""
	def replace( base_map_list, add_map_list, match_key ) do
		adds = add_map_list |> Enum.map( &( &1[ match_key ] ) )
		match_map_list = base_map_list
			|> Enum.filter( &( adds |> Enum.member?( &1[ match_key ] ) ) )
			|> Enum.map( &( Map.merge( &1, find( add_map_list, &1, match_key ) ) ) )
		nomatch_map_list = no_match_maps( base_map_list, add_map_list, match_key )
		match_map_list ++ nomatch_map_list
	end

	@doc """
	Get maps that do not match value of key

	## Examples
		iex> MapList.no_match_maps( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], [ %{ "a" => "key1", "c" => 13 }, %{ "a" => "key3", "c" => 22 } ], "a" )
		[ %{ "a" => "key2", "b" => 22 } ]
		iex> MapList.no_match_maps( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], [ %{ "a" => "key3", "c" => 13 } ], "a" )
		[ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ]
		iex> MapList.no_match_maps( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], [ %{ "a" => "key1", "c" => 13 }, %{ "a" => "key2", "c" => 22 } ], "a" )
		[]
	"""
	def no_match_maps( base_map_list, match_map_list, match_key ) do
		matchs = match_map_list |> Enum.map( &( &1[ match_key ] ) )
		base_map_list
		|> Enum.filter( &( !( matchs |> Enum.member?( &1[ match_key ] ) ) ) )
	end

	@doc """
	Find map 

	## Examples
		iex> MapList.find( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], %{ "a" => "key1" }, "a" )
		%{ "a" => "key1", "b" => 12 }
		iex> MapList.find( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], %{ "a" => "key2" }, "a" )
		%{ "a" => "key2", "b" => 22 }
		iex> MapList.find( [ %{ "a" => "key1", "b" => 12 }, %{ "a" => "key2", "b" => 22 } ], %{ "a" => "key3" }, "a" )
		nil
	"""
	def find( map_list, match_map, match_key ) do
		map_list |> Enum.find( fn( %{ ^match_key => value } ) -> match_map[ match_key ] == value end )
	end

	@doc """
	Make extracted keys map without specified key

	## Examples
		iex> MapList.make_extracted_keys_map_exclude_key( [ %{ "a" => "key1", "b" => 12, "c" => 13 }, %{ "a" => "key2", "b" => 22 } ], "a", "new_value" )
		%{"b" => "new_value", "c" => "new_value"}
	"""
	def make_extracted_keys_map_exclude_key( map_list, exclude_key, no_match_value ) do
		keys = map_list
			|> List.first
			|> Map.delete( exclude_key )
			|> Map.keys
		Lst.zip( keys, List.duplicate( no_match_value, Enum.count( keys ) ) )
	end
end
