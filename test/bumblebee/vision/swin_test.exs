defmodule Bumblebee.Vision.SwinTest do
  use ExUnit.Case, async: true

  import Bumblebee.TestHelpers

  @moduletag model_test_tags()

  test ":base" do
    assert {:ok, %{model: model, params: params, spec: spec}} =
             Bumblebee.load_model({:hf, "hf-internal-testing/tiny-random-SwinModel"})

    assert %Bumblebee.Vision.Swin{architecture: :base} = spec

    inputs = %{
      "pixel_values" => Nx.broadcast(0.5, {1, 30, 30, 3})
    }

    outputs = Axon.predict(model, params, inputs)

    assert Nx.shape(outputs.hidden_state) == {1, 16, 64}
    assert Nx.shape(outputs.pooled_state) == {1, 64}

    assert_all_close(
      outputs.hidden_state[[.., 1..3, 1..3]],
      Nx.tensor([
        [[-0.4605, 0.9336, -0.5528], [-0.4449, 0.8927, -0.5424], [-0.5024, 0.2263, 0.2208]]
      ])
    )

    assert_all_close(
      outputs.pooled_state[[.., 1..3]],
      Nx.tensor([[-0.5004, 0.4605, -0.4949]])
    )
  end

  test ":for_image_classification" do
    assert {:ok, %{model: model, params: params, spec: spec}} =
             Bumblebee.load_model(
               {:hf, "hf-internal-testing/tiny-random-SwinForImageClassification"}
             )

    assert %Bumblebee.Vision.Swin{architecture: :for_image_classification} = spec

    inputs = %{
      "pixel_values" => Nx.broadcast(0.5, {1, 30, 30, 3})
    }

    outputs = Axon.predict(model, params, inputs)

    assert Nx.shape(outputs.logits) == {1, 2}

    assert_all_close(
      outputs.logits,
      Nx.tensor([[0.0834, 0.1265]])
    )
  end

  # TODO remove before merging
  test ":for_image_classification actual" do
    assert {:ok, %{model: model, params: params, spec: spec}} =
             Bumblebee.load_model({:hf, "microsoft/swin-base-patch4-window12-384"})

    assert %Bumblebee.Vision.Swin{architecture: :for_image_classification} = spec

    inputs = %{
      "pixel_values" => Nx.broadcast(0.5, {1, 384, 384, 3})
    }

    outputs = Axon.predict(model, params, inputs)

    assert Nx.shape(outputs.logits) == {1, 1000}

    compare = outputs.logits[[0, 0..9]]

    assert_all_close(
      compare,
      Nx.tensor([
        [
          6.9526e-02,
          8.5011e-01,
          4.5132e-01,
          5.4306e-01,
          2.4646e-01,
          -2.2765e-03,
          6.9874e-02,
          1.3368e-01,
          4.6875e-01,
          8.8567e-01
        ]
      ])
    )
  end
end
