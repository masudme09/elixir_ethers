defmodule Ethers.UtilsTest do
  use ExUnit.Case
  alias Ethers.Utils
  doctest Ethers.Utils

  describe "get_block_timestamp" do
    test "returns the block timestamp" do
      assert {:ok, n} = Ethers.current_block_number()
      assert {:ok, t} = Utils.get_block_timestamp(n)
      assert abs(System.system_time(:second) - t) < 100
    end

    test "can override the rpc opts" do
      assert {:ok, 500} =
               Utils.get_block_timestamp(100,
                 rpc_client: Ethers.TestRPCModule,
                 rpc_opts: [timestamp: 400]
               )
    end
  end

  describe "date_to_block_number" do
    test "calculates the right block number for a given date" do
      assert {:ok, n} = Ethers.current_block_number()
      assert {:ok, ^n} = Utils.date_to_block_number(DateTime.utc_now())
      assert {:ok, ^n} = Utils.date_to_block_number(DateTime.utc_now(), n)
      assert {:ok, ^n} = Utils.date_to_block_number(DateTime.utc_now() |> DateTime.to_unix())
    end

    test "can override the rpc opts" do
      assert {:ok, 1001} =
               Utils.date_to_block_number(
                 1000,
                 nil,
                 rpc_client: Ethers.TestRPCModule,
                 rpc_opts: [timestamp: 111, block: "0x3E9"]
               )

      assert {:ok, 1_693_699_060} =
               Utils.date_to_block_number(
                 ~D[2023-09-03],
                 nil,
                 rpc_client: Ethers.TestRPCModule,
                 rpc_opts: [timestamp: 123, block: "0x1"]
               )
    end
  end

  describe "maybe_add_gas_limit" do
    test "does not add anything if the params already includes gas" do
      assert {:ok, %{gas: :untouched}} = Ethers.Utils.maybe_add_gas_limit(%{gas: :untouched})
    end
  end

  describe "hex_to_integer!" do
    test "raises when the hex input is invalid" do
      assert_raise ArgumentError,
                   "Invalid integer HEX input \"0xrubbish\" reason :invalid_hex",
                   fn -> Ethers.Utils.hex_to_integer!("0xrubbish") end
    end
  end

  describe "hex_decode!" do
    test "raises when the hex input is invalid" do
      assert_raise ArgumentError,
                   "Invalid HEX input \"0xrubbish\"",
                   fn -> Ethers.Utils.hex_decode!("0xrubbish") end
    end
  end
end
