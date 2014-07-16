require 'spec_helper'

module LightService
  describe ":promises macro" do
    class DummyActionForKeysToPromise
      include LightService::Action
      expects :tea, :milk
      promises :milk_tea

    end

    context "when the promised key is not in the context" do
      it "raises an ArgumentError" do
        class DummyActionForKeysToPromise
          executed do |context|
            context[:some_tea] = "#{context.tea} - #{context.milk}"
          end
        end

        exception_error_text = "promised :milk_tea to be in the context during LightService::DummyActionForKeysToPromise"
        expect {
          DummyActionForKeysToPromise.execute(:tea => "black", :milk => "full cream")
        }.to raise_error(PromisedKeysNotInContextError, exception_error_text)
      end

      it "it can fail the context without fulfilling its promise" do
        class DummyActionForKeysToPromise
          executed do |context|
            context.fail!("Sorry, something bad has happened.")
          end
        end

        result_context = DummyActionForKeysToPromise.execute(:tea => "black",
                                                             :milk => "full cream")

        expect(result_context).to be_failure
        expect(result_context.keys).not_to include(:milk_tea)
      end
    end

    context "when the promised key is in the context" do
      it "can be set with an actual value" do
        class DummyActionForKeysToPromise
          executed do |context|
            context.milk_tea = "#{context.tea} - #{context.milk}"
            context.milk_tea += " hello"
          end
        end

        result_context = DummyActionForKeysToPromise.execute(:tea => "black",
                                                             :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to eq("black - full cream hello")
      end

      it "can be set with nil" do
        class DummyActionForKeysToPromise
          executed do |context|
            context.milk_tea = nil
          end
        end
        result_context = DummyActionForKeysToPromise.execute(:tea => "black",
                                                             :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to be_nil
      end
    end
  end
end
