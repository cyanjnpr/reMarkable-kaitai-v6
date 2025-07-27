# tested only on files produced by xochitl 3.8.2
meta:
  id: rm_v6
  title: reMarkable .lines file, version=6
  file-extension: rm
  application: xochitl
  endian: le
  imports:
    - leb128
seq:
  - id: header
    type: str
    size: 43
    encoding: ASCII
  - id: packets
    type: packet
    repeat: eos
types:
  packet_header:
    seq:
      - id: length
        type: u4
      - id: first_version
        type: u1
      - id: minimal_version
        type: u1
      - id: version
        type: u1
      - id: header_type
        type: u1
        enum: packet_type
    instances:
      len:
        value: 8
  sig_id:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x0F
  sig_len:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x0C
  sig_u1:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x01
  sig_u2:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x02
  sig_u4:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x04
  sig_dbl:
    seq:
      - id: sig
        type: u1
        valid:
          expr: _ & 0x0F == 0x08

  id_field:
    seq:
      - id: major
        type: leb128
      - id: minor
        type: leb128
    instances:
      len:
        value: major.len + minor.len

  positioned_packet:
    seq:
      - id: id_sig
        type: sig_id
      - id: id
        type: id_field
      - id: left_sig
        type: sig_id
      - id: left
        type: id_field
      - id: right_sig
        type: sig_id
      - id: right
        type: id_field
      - id: deleted_length_sig
        type: sig_u4
      - id: deleted_length
        type: u4
    instances:
      len:
        value: 8 + id.len + left.len + right.len

  positioned_child_packet:
    seq:
      - id: parent_id_sig
        type: sig_id
      - id: parent_id
        type: id_field
      - id: child_packet
        type: positioned_packet
    instances:
      len:
        value: 1 + parent_id.len + child_packet.len

  uuid_packet:
    seq:
      - id: unknown_byte_1
        type: u1
      - id: uuid_length_sig
        type: sig_len
      - id: uuid_packet_length
        type: u4
      - id: uuid_length
        type: u1
      - id: uuid
        type: u1
        repeat: expr
        repeat-expr: 16
      - id: second
        type: u1
      - id: unknown_byte_2
        type: u1
    instances:
      len:
        value: 25

  migration_info_packet:
    seq:
      - id: migration_id_sig
        type: sig_id
      - id: migration_id
        type: id_field
      - id: device_sig
        type: sig_u1
      - id: device
        type: u1
      - id: v3_sig
        type: sig_u1
      - id: v3
        type: u1
    instances:
      len:
        value: 5 + migration_id.len

  page_stats_packet:
    seq:
      - id: loads_sig
        type: sig_u4
      - id: loads
        type: u4
      - id: merges_sig
        type: sig_u4
      - id: merges
        type: u4
      - id: text_chars_sig
        type: sig_u4
      - id: text_chars
        type: u4
      - id: text_lines_sig
        type: sig_u4
      - id: text_lines
        type: u4
      - id: keyboard_count_sig
        type: sig_u4
      - id: keyboard_count
        type: u4
    instances:
      len:
        value: 25

  scene_info_current_layer:
    seq:
      - id: current_layer_sig
        type: sig_len
      - id: current_layer_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_id
      - id: value
        type: id_field
    instances:
      len:
        value: 7 + timestamp.len + value.len

  scene_info_background_visible:
    seq:
      - id: background_visible_sig
        type: sig_len
      - id: background_visible_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_u1
      - id: value
        type: u1
    instances:
      len:
        value: 8 + timestamp.len

  scene_info_root_document_visible:
    seq:
      - id: root_document_visible_sig
        type: sig_len
      - id: root_document_visible_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_u1
      - id: value
        type: u1
    instances:
      len:
        value: 8 + timestamp.len

  scene_info_packet:
    seq:
      - id: current_layer
        type: scene_info_current_layer
      - id: background_visible
        type: scene_info_background_visible
      - id: root_document_visible
        type: scene_info_root_document_visible
    instances:
      len:
        value: current_layer.len + background_visible.len + root_document_visible.len

  scene_tree_move_packet:
    seq:
      - id: id_sig
        type: sig_id
      - id: id
        type: id_field
      - id: node_sig
        type: sig_id
      - id: node
        type: id_field
      - id: item_sig
        type: sig_u1
      - id: item
        type: u1
      - id: parent_length_sig
        type: sig_len
      - id: parent_length
        type: u4
      - id: parent_sig
        type: sig_id
      - id: parent_id
        type: id_field
    instances:
      len:
        value: 10 + id.len + node.len + parent_id.len

  text:
    seq:
      - id: text_length_sig
        type: sig_len
      - id: text_length
        type: u4
      - id: stripped_text_length
        type: leb128
      - id: unknown_byte
        type: u1
      - id: text
        type: str
        size: stripped_text_length.value
        encoding: UTF-8
    instances:
      len:
        value: 6 + stripped_text_length.value + stripped_text_length.len

  text_item:
    seq:
      - id: text_item_length_sig
        type: sig_len
      - id: text_item_length
        type: u4
      - id: positioned_packet
        type: positioned_packet
      - id: text
        type: text
        if: positioned_packet.deleted_length == 0
      - id: font_weight_sig
        type: sig_u4
        if: positioned_packet.deleted_length == 0 and
          text_item_length > text.len + positioned_packet.len
      - id: font_weight
        type: u4
        if: positioned_packet.deleted_length == 0 and
          text_item_length > text.len + positioned_packet.len
    instances:
      len:
        value: 'positioned_packet.deleted_length == 0 ? 
          10 + positioned_packet.len + text.len : 
          5 + positioned_packet.len'

  text_style:
    seq:
      - id: key
        type: id_field
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: style_length_sig
        type: sig_len
      - id: style_length
        type: u4
      - id: style_sig
        type: sig_u1
      - id: style
        type: u1
    instances:
      len:
        value: 8 + key.len + timestamp.len

  text_position:
    seq:
      - id: root_text_length_sig
        type: sig_len
      - id: root_text_length
        type: u4
      - id: styles_length_sig
        type: sig_len
      - id: styles_length
        type: u4
      - id: num_styles
        type: leb128
      - id: styles
        type: text_style
        repeat: expr
        repeat-expr: num_styles.value
      - id: position_length_sig
        type: sig_len
      - id: position_length
        type: u4
      - id: x
        type: f8
      - id: y
        type: f8
      - id: text_width_sig
        type: sig_u4
      - id: text_width
        type: f4
    instances:
      # without array
      len:
        value: 36 + num_styles.len

  text_packet:
    seq:
      - id: parent_id_sig
        type: sig_id
      - id: parent_id
        type: id_field
      - id: length_with_styles_sig
        type: sig_len
      - id: length_with_styles
        type: u4
      - id: length_with_text_sig
        type: sig_len
      - id: length_with_text
        type: u4
      - id: length_with_text_inner_sig
        type: sig_len
      - id: length_with_text_inner
        type: u4
      - id: num_items
        type: leb128
      - id: items
        type: text_item
        repeat: expr
        repeat-expr: num_items.value
      - id: position
        type: text_position
    instances:
      # without array
      len:
        value: 16 + parent_id.len + num_items.len + position.len

  scene_tree_node_packet:
    seq:
      - id: id_sig
        type: sig_id
      - id: id
        type: id_field
      - id: name_length_sig
        type: sig_len
      - id: name_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: name
        type: text
      - id: node_length_sig
        type: sig_len
      - id: node_length
        type: u4
      - id: node_sig
        type: sig_id
      - id: node
        type: id_field
      - id: node_value_sig
        type: sig_u1
      - id: node_value
        type: u1
    instances:
      len:
        value: 15 + id.len + timestamp.len + name.len + node.len

  anchor_id:
    seq:
      - id: anchor_id_length_sig
        type: sig_len
      - id: anchor_id_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_id
      - id: value
        type: id_field
    instances:
      len:
        value: 6 + timestamp.len + value.len

  anchor_mode:
    seq:
      - id: anchor_mode_length_sig
        type: sig_len
      - id: unknown_byte
        type: u1
      - id: anchor_mode_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_u1
      - id: value
        type: u1
    instances:
      len:
        value: 9 + timestamp.len

  anchor_threshold_id:
    seq:
      - id: anchor_threshold_length_sig
        type: sig_len
      - id: uknown_byte
        type: u1
      - id: anchor_threshold_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_u4
      - id: value
        type: f4
    instances:
      len:
        value: 12 + timestamp.len

  anchor_initial_origin_x:
    seq:
      - id: anchor_initial_origin_length_sig
        type: sig_len
      - id: unknown_byte
        type: u1
      - id: anchor_initial_origin_length
        type: u4
      - id: timestamp_sig
        type: sig_id
      - id: timestamp
        type: id_field
      - id: value_sig
        type: sig_u4
      - id: value
        type: f4
    instances:
      len:
        value: 12 + timestamp.len

  scene_tree_node_anchor:
    seq:
      - id: id
        type: anchor_id
      - id: mode
        type: anchor_mode
      - id: threshold
        type: anchor_threshold_id
      - id: origin
        type: anchor_initial_origin_x
    instances:
      len:
        value: id.len + mode.len + threshold.len + origin.len

  crdt_group_item_node:
    seq:
      - id: node_id_length_sig
        type: sig_len
      - id: node_id_length
        type: u4
      - id: stripped_node_id_length
        type: leb128
      - id: unknown_byte
        type: u1
      - id: node_id
        type: id_field
    instances:
      len:
        value: 6 + stripped_node_id_length.len + node_id.len

  crdt_group_item_packet:
    seq:
      - id: positioned_packet
        type: positioned_child_packet
      - id: node
        type: crdt_group_item_node
        if: positioned_packet.child_packet.deleted_length == 0
    instances:
      len:
        value: 'positioned_packet.child_packet.deleted_length == 0 ?
          positioned_packet.len + node.len :
          positioned_packet.len'

  point:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: speed
        type: u2
      - id: width
        type: u2
      - id: direction
        type: u1
      - id: pressure
        type: u1
    instances:
      len:
        value: 14
      speed_value:
        value: speed / 4.0
      width_value:
        value: width / 4.0
      direction_value:
        value: direction * 2 * 3.14 / 255.0
      pressure_value:
        value: pressure / 255.0

  crdt_line_item_points:
    seq:
      - id: length_sig
        type: sig_len
      - id: length
        type: u4
      - id: unknown_byte
        type: u1
      - id: tool_sig
        type: sig_u4
      - id: tool
        type: u4
      - id: color_sig
        type: sig_u4
      - id: color
        type: u4
      - id: thickness_scale_sig
        type: sig_dbl
      - id: thickness_scale
        type: f8
      - id: starting_length_sig
        type: sig_u4
      - id: starting_length
        type: u4
      - id: points_length_sig
        type: sig_len
      - id: points_length
        type: u4
      - id: points
        type: point
        repeat: expr
        repeat-expr: points_length / 14
      - id: ts_sig
        type: sig_id
      - id: ts
        type: id_field
      - id: move_id_sig
        type: sig_id
        if: length - points_length - 33 > 0
      - id: move_id
        type: id_field
        if: length - points_length - 33 > 0
    instances:
      len:
        # without array
        value: 'length - points_length - 33 > 0 ?
          37 + ts.len + move_id.len :
          36 + ts.len'

  crdt_line_item_packet:
    seq:
      - id: positioned_packet
        type: positioned_child_packet
      - id: points
        type: crdt_line_item_points
        if: positioned_packet.child_packet.deleted_length == 0
    instances:
      len:
        value: 'positioned_packet.child_packet.deleted_length == 0 ?
          positioned_packet.len + points.len :
          positioned_packet.len'

  glyph_rect:
    seq:
      - id: rect_length_sig
        type: sig_len
      - id: rect_length
        type: u4
      - id: unknown_byte
        type: u1
      - id: x
        type: f8
      - id: y
        type: f8
      - id: width
        type: f8
      - id: height
        type: f8
    instances:
      len:
        value: 38

  crdt_glyph_item_value:
    seq:
      - id: length_sig
        type: sig_len
      - id: length
        type: u4
      - id: unknown_byte_1
        type: u1
      - id: color_sig
        type: sig_u4
      - id: color
        type: u4
      - id: text
        type: text
      - id: rect
        type: glyph_rect
      - id: first_sig
        type: sig_id
      - id: first
        type: id_field
      - id: last_sig
        type: sig_id
      - id: unknown_byte_2
        type: u1
      - id: last
        type: id_field
      - id: include_last_id_sig
        type: sig_u1
      - id: unknown_byte_3
        type: u1
      - id: include_last_id
        type: u1
    instances:
      len:
        value: 17 + text.len + rect.len + first.len + last.len

  crdt_glyph_item_packet:
    seq:
      - id: positioned_packet
        type: positioned_child_packet
      - id: value
        type: crdt_glyph_item_value
        if: positioned_packet.child_packet.deleted_length == 0
    instances:
      len:
        value: 'positioned_packet.child_packet.deleted_length == 0 ?
          positioned_packet.len + value.len :
          positioned_packet.len'

  packet:
    seq:
      - id: packet_header
        type: packet_header
      - id: packet_body
        type:
          switch-on: packet_header.header_type
          cases:
            'packet_type::uuid': uuid_packet
            'packet_type::migration': migration_info_packet
            'packet_type::stats': page_stats_packet
            'packet_type::scene': scene_info_packet
            'packet_type::tree_move': scene_tree_move_packet
            'packet_type::text_item': text_packet
            'packet_type::tree_node': scene_tree_node_packet
            'packet_type::group_item': crdt_group_item_packet
            'packet_type::line_item': crdt_line_item_packet
            'packet_type::glyph_item': crdt_glyph_item_packet
      - id: scene_tree_node_anchor
        type: scene_tree_node_anchor
        if: packet_header.header_type == packet_type::tree_node and 
          packet_body.as<scene_tree_node_packet>.len < packet_header.length

enums:
  packet_type:
    0x00: migration
    0x01: tree_move
    0x02: tree_node
    0x03: glyph_item
    0x04: group_item
    0x05: line_item
    0x07: text_item
    0x09: uuid
    0x0a: stats
    0x0d: scene
