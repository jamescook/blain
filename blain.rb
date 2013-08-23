require "ffi"

class Blain
  class YajlBinding
    extend FFI::Library


    ffi_lib "/usr/local/lib/libyajl.so"

    callback :yajl_null,        [:pointer], :int
    callback :yajl_boolean,     [:pointer, :int], :int
    callback :yajl_integer,     [:pointer, :long_long], :int
    callback :yajl_double,      [:pointer, :double], :int
    callback :yajl_number,      [:pointer, :string, :size_t], :int
    callback :yajl_string,      [:pointer, :string, :size_t], :int
    callback :yajl_start_map,   [:pointer], :int
    callback :yajl_map_key,     [:pointer, :string, :size_t], :int
    callback :yajl_end_map,     [:pointer], :int
    callback :yajl_start_array, [:pointer], :int
    callback :yajl_end_array,   [:pointer], :int

    callback :yajl_print_t,     [:pointer, :string, :size_t], :void

    class YajlCallbacks < FFI::Struct
        layout :yajl_callback_null,        :yajl_null,
               :yajl_callback_boolean,     :yajl_boolean,
               :yajl_callback_integer,     :yajl_integer,
               :yajl_callback_double,      :yajl_double,
               :yajl_callback_number,      :yajl_number,
               :yajl_callback_string,      :yajl_string,
               :yajl_callback_start_map,   :yajl_start_map,
               :yajl_callback_map_key,     :yajl_map_key,
               :yajl_callback_end_map,     :yajl_end_map,
               :yajl_callback_start_array, :yajl_start_array,
               :yajl_callback_end_array,   :yajl_end_array
    end

    class YajlHandle < FFI::Struct
      layout :callbacks, :pointer,
             :afs,       :pointer,
             :ctx,       :pointer
    end

    enum :yajl_gen_state, [ :yajl_gen_start, :yajl_gen_map_start, :yajl_gen_map_key, :yajl_gen_map_val, :yajl_gen_array_start, :yajl_gen_in_array, :yajl_gen_complete, :yajl_gen_error ]

    class YajlGenT < FFI::Struct
      layout :flags,            :uint,
             :depth,            :uint,
             :identString,      :string,
             :state,            :yajl_gen_state,
             :print,            :yajl_print_t,
             :ctx,              :pointer,
             :yajl_alloc_funcs, :pointer #memory alloc/dealloc funcs
    end

    enum :yajl_gen_status, [ :yajl_gen_status_ok, :yajl_gen_keys_must_be_strings, :yajl_max_depth_exceeded, :yajl_gen_in_error_state, :yajl_gen_generation_complete, :yajl_gen_invalid_number, :yajl_gen_no_buf ]

    enum :yajl_status, [ :yajl_status_ok, :yajl_status_client_canceled, :yajl_status_error ]

    #attach_variable :yajl_handle, :yajl_handle_t, YajlHandle
    attach_function "yajl_gen_null", [YajlGenT], :yajl_gen_status
    attach_function "yajl_parse", [YajlHandle, :string, :size_t], :yajl_status
    attach_function "yajl_alloc", [:pointer, :pointer, :pointer], YajlHandle
  end

  attr_reader :alloc

  def initialize(input)
    @input = input
  end

  def parse
    pointer1 = FFI::MemoryPointer.new(:void)
    pointer2 = FFI::MemoryPointer.new(:void)
    @alloc = YajlBinding.yajl_alloc( YajlBinding::YajlCallbacks.new(:yajl_gen_null), nil, pointer2)
    YajlBinding.yajl_parse(@alloc, @input, @input.size)
  end

  def alloc
    YajlBinding::YajlHandle.new(@alloc)
  end
end
