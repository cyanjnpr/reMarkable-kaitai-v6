#include <type/leb128.pat>

// tested on .rm files produced by xochitl 3.8.2

struct Header {
    char header[43] [[color("FF0000")]];
};

enum PacketType : u8 {
    Uuid = 0x09,
    Migration = 0x00,
    Stats = 0x0A,
    Scene = 0x0D,
    TreeMove = 0x01,
    TextItem = 0x07,
    TreeNode = 0x02,
    GroupItem = 0x04,
    LineItem = 0x05,
    GlyphItem = 0x03
};

fn is_id_sig(u8 sig) {
    return (sig & 0x0F) == 0x0F;
};

fn is_len_sig(u8 sig) {
    return (sig & 0x0F) == 0x0C;
};

fn is_u8_sig(u8 sig) {
    return (sig & 0x0F) == 0x01;
};

fn is_u16_sig(u8 sig) {
    return (sig & 0x0F) == 0x02;
};

fn is_u32_sig(u8 sig) {
    return (sig & 0x0F) == 0x04;
};

fn is_dbl_sig(u8 sig) {
    return (sig & 0x0F) == 0x08;
};

fn format_id(ref auto id) {
    return std::format("{}:{}", id.id_major, id.id_minor);
};

struct ID {
    type::uLEB128 id_major;
    type::uLEB128 id_minor;
} [[sealed, format("format_id")]];

struct PositionedPacket {
    u8 id_sig;
    ID id;
    u8 left_sig;
    ID left;
    u8 right_sig;
    ID right;
    u8 deleted_length_sig;
    u32 deleted_length;
    
    if (is_id_sig(id_sig) && is_id_sig(left_sig) &&
        is_id_sig(right_sig) && is_u32_sig(deleted_length_sig)) {
    } else {
        break;
    }
};

struct PositionedChildPacket {
    u8 parent_id_sig;
    ID parent_id;
    PositionedPacket packet;
    
    if (is_id_sig(parent_id_sig)) {
    } else {
        break;
    }
};

struct PacketHeader {
    // length of the packet excluding this header
    u32 length [[color("FF0000")]];
    // not sure about this one
    u8 first_version;
    u8 minimal_version;
    u8 version;
    PacketType type;
} [[color("BF0000")]];

struct UuidPacket {
    u8 unknown_byte_1;
    u8 uuid_length_sig;
    u32 uuid_packet_length;
    u8 uuid_length;
    u8 uuid[16];
    u8 second;
    u8 unknown_byte_2;
    
    if (is_len_sig(uuid_length_sig)) {
    } else {
        break;
    }
} [[name("Uuid Packet"), color("fabd2f")]];

struct MigrationInfo {
    u8 migration_id_sig;
    ID migration_id;
    u8 device_sig;
    u8 device;
    u8 v3_sig;
    u8 v3;
    
    if (is_id_sig(migration_id_sig) && is_u8_sig(device_sig) &&
    is_u8_sig(v3_sig)) {
    } else {
        break;
    }
} [[name("MigrationInfo Packet"), color("8ec07c")]];

struct PageStats {
    u8 loads_sig;
    u32 loads;
    u8 merges_sig;
    u32 merges;
    u8 text_chars_sig;
    u32 text_chars;
    u8 text_lines_sig;
    u32 text_lines;
    u8 keyboard_count_sig;
    u32 keyboard_count;
    
    if (is_u32_sig(loads_sig) && is_u32_sig(merges_sig) &&
        is_u32_sig(text_chars_sig) && is_u32_sig(text_lines_sig) &&
        is_u32_sig(keyboard_count_sig)) {
    } else {
        break;
    }
} [[name("PageStats Packet"), color("d3869b")]];

struct SceneInfoCurrentLayer {
    u8 current_layer_sig;
    u32 current_layer_length;
    
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    ID value;
    
    if (is_len_sig(current_layer_sig) && is_id_sig(timestamp_sig) &&
        is_id_sig(value_sig)) {
    } else {
        break;
    }
};

struct SceneInfoBackgroundVisible {
    u8 background_visible_sig;
    u32 background_visible_length;
    
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    u8 value;
    
    if (is_len_sig(background_visible_sig) && is_id_sig(timestamp_sig) &&
        is_u8_sig(value_sig)) {
    } else {
        break;
    }
};

struct SceneInfoRootDocumentVisible {
    u8 root_document_visible_sig;
    u32 root_document_visible_length;
    
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    u8 value;
    
    if (is_len_sig(root_document_visible_sig) && is_id_sig(timestamp_sig) &&
        is_u8_sig(value_sig)) {
    } else {
        break;
    }
};

struct SceneInfo {
    SceneInfoCurrentLayer current;
    SceneInfoBackgroundVisible background;
    SceneInfoRootDocumentVisible root;
} [[name("SceneInfo Packet"), color("83a598")]];

struct SceneTreeMove {
    u8 id_sig [[color("98971a")]];
    ID id;
    u8 node_sig;
    ID node;
    u8 item_sig;
    u8 item;
    u8 parent_length_sig;
    u32 parent_length;
    u8 parent_sig;
    ID parent_id;
    
    if (is_id_sig(id_sig) && is_id_sig(node_sig) &&
        is_u8_sig(item_sig) && is_len_sig(parent_length_sig) &&
        is_id_sig(parent_sig)) {
    } else {
        break;
    }
} [[name("SceneTreeMove Packet"), color("b8bb26")]];

struct Text {
    u8 text_length_sig;
    u32 text_length;
    type::uLEB128 stripped_text_length;
    u8 unknown_byte;
    char text[stripped_text_length];
    
    if (is_len_sig(text_length_sig)) {
    } else {
        break;
    }
} [[color("689d6a")]];

struct TextItem {
    u8 text_item_length_sig;
    u32 text_item_length;
    PositionedPacket packet;
    
    if (packet.deleted_length == 0) {
        Text text;
        
        if (text_item_length > sizeof(packet) + sizeof(text)) {
            u8 font_weight_sig;
            u32 font_weight;
            if (is_u32_sig(font_weight_sig)) {
            } else {
                break;
            }
        } 
    }
    
    if (is_len_sig(text_item_length_sig)) {
    } else {
        break;
    }
} [[color("8ec07c")]];

struct TextStyle {
    ID key;
    u8 timestamp_sig;
    ID timestamp;
    
    u8 style_length_sig;
    u32 style_length;
    u8 style_sig;
    u8 style;
    
    if (is_id_sig(timestamp_sig) && is_len_sig(style_length_sig) &&
        is_u8_sig(style_sig)) {
    } else {
        break;
    }
} [[color("d79921")]];

struct TextPosition {
    u8 root_text_length_sig;
    u32 root_text_length;
    
    u8 styles_length_sig;
    u32 styles_length;
    
    type::uLEB128 styles_number;
    TextStyle styles[styles_number];

    u8 position_length_sig;
    u32 position_length;
    double x;
    double y;
    u8 text_width_sig;
    float text_width;
    
    if (is_len_sig(root_text_length_sig) && is_len_sig(styles_length_sig) &&
        is_len_sig(position_length_sig) && is_u32_sig(text_width_sig)) {
    } else {
        break;
    }
};

struct TextPacket {
    u8 parent_id_sig;
    ID parent_id;
    u8 length_with_styles_sig;
    u32 length_with_styles;
    u8 length_with_text_sig;
    u32 length_with_text;
    u8 length_with_text_inner_sig;
    u32 length_with_text_inner;
    
    type::uLEB128 items_number;
    TextItem items[items_number];
    TextPosition position;
    
    if (is_id_sig(parent_id_sig) && is_len_sig(length_with_styles_sig) &&
    is_len_sig(length_with_text_sig) && is_len_sig(length_with_text_inner_sig)) {
    } else {
        break;
    }
} [[name("Text Packet"), color("fabd2f")]];

struct SceneTreeNode {
    u8 id_sig;
    ID id;
    u8 name_length_sig;
    u32 name_length;
    u8 timestamp_sig;
    ID timestamp;
    Text name;
    
    u8 node_length_sig;
    u32 node_length;
    
    u8 node_sig;
    ID node;
    u8 node_value_sig;
    u8 node_value;
    
    if (is_id_sig(id_sig) && is_len_sig(name_length_sig) &&
        is_id_sig(timestamp_sig) && is_len_sig(node_length_sig) &&
        is_id_sig(node_sig) && is_u8_sig(node_value_sig)) {
    } else {
        break;
    }
} [[name("SceneTreeNode Packet"), color("d3869b")]];

struct AnchorId {
    u8 anchor_id_length_sig;
    u32 anchor_id_length;
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    ID value;
    
    if (is_len_sig(anchor_id_length_sig) && is_id_sig(timestamp_sig) &&
        is_id_sig(value_sig)) {
    } else {
        break;
    }
};

struct AnchorMode {
    u8 anchor_mode_length_sig;
    u8 unknown_byte;
    u32 anchor_mode_length;
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    u8 value;
    
    if (is_len_sig(anchor_mode_length_sig) && is_id_sig(timestamp_sig) &&
        is_u8_sig(value_sig)) {
    } else {
        break;
    }
};

struct AnchorThreshold {
    u8 anchor_threshold_length_sig;
    u8 unknown_byte;
    u32 anchor_threshold_length;
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    float value;
    
    if (is_len_sig(anchor_threshold_length_sig) && is_id_sig(timestamp_sig) &&
        is_u32_sig(value_sig)) {
    } else {
        break;
    }
};

struct AnchorInitialOriginX {
    u8 anchor_initial_origin_length_sig;
    u8 unknown_byte;
    u32 anchor_initial_origin_length;
    u8 timestamp_sig;
    ID timestamp;
    u8 value_sig;
    float value;
    
    if (is_len_sig(anchor_initial_origin_length_sig) && is_id_sig(timestamp_sig) &&
        is_u32_sig(value_sig)) {
    } else {
        break;
    }
};

// there is no other indication of this piece in the packet
// other than the overall length as far as i am aware
struct SceneTreeNodeAnchor {
    AnchorId id;
    AnchorMode mode;
    AnchorThreshold threshold;
    AnchorInitialOriginX origin;
} [[color("b16286")]];

struct CrdtGroupItemNode {
    u8 node_id_length_sig;
    u32 node_id_length;
    u8 unknown_byte;
    u8 node_id_sig;
    ID node_id;
    
    if (is_len_sig(node_id_length_sig) && is_id_sig(node_id_sig)) {
    } else {
        break;
    }
};

struct CrdtGroupItem {
    PositionedChildPacket packet;
    
    if (packet.packet.deleted_length == 0) {
        CrdtGroupItemNode node;
    }
} [[name("CrdtGroupItem Packet"), color("83a598")]];

fn format_speed(u16 speed) {
    return speed / 4f;
};

fn format_direction(u8 direction) {
    return direction * 2 * 3.14 / 255f;
};

fn format_pressure(u8 pressure) {
    return pressure / 255f;
};

struct Point {
    float x [[color("fabd2f")]];
    float y [[color("fabd2f")]];
    u16 speed [[format("format_speed")]];
    u16 width [[format("format_speed"), color("8ec07c")]];
    u8 direction [[format("format_direction")]];
    u8 pressure [[format("format_pressure"), color("8ec07c")]];
};

fn transform_points_xs(ref auto points, u32 num_points) {
    std::mem::Section section = std::mem::create_section("Section");
    for (u32 i = 0, i < num_points*4, i += 4) {
      float float_value @ i in section;
    
      float_value = points[i/4].x;
    }
    float arr[num_points] @ 0x00 in section;
    return arr;
};

fn transform_points_ys(ref auto points, u32 num_points) {
    std::mem::Section section = std::mem::create_section("Section");
    for (u32 i = 0, i < num_points*4, i += 4) {
      float float_value @ i in section;
      // reverse coords
      float_value = -points[i/4].y;
    }
    float arr[num_points] @ 0x00 in section;
    return arr;
};

struct CrdtLineItemPoints {
    u8 length_sig;
    u32 length;
    u8 unknown_byte;
    
    u8 tool_sig;
    u32 tool;
    u8 color_sig;
    u32 color;
    u8 thickness_scale_sig;
    double thickness_scale;
    u8 starting_length_sig;
    u32 starting_length;
    
    u8 points_length_sig;
    u32 points_length;
    u32 num_points = points_length / sizeof(Point);
    Point points[num_points];
    u8 ts_sig;
    ID ts;
    if (length - points_length - 33 > 0) {
        u8 move_id_sig;
        ID move_id;
        
        if (is_id_sig(move_id_sig)) {
        } else {
            break;
        }
    }
    
    if (is_len_sig(length_sig) && is_u32_sig(tool_sig) &&
        is_u32_sig(color_sig) && is_u32_sig(starting_length_sig) &&
        is_len_sig(points_length_sig) && is_id_sig(ts_sig) &&
        is_dbl_sig(thickness_scale_sig)) {
    } else {
        break;
    }
} [[hex::visualize("scatter_plot", 
        transform_points_xs(points, num_points), 
        transform_points_ys(points, num_points))]];

struct CrdtLineItem {
    PositionedChildPacket positioned;
    
    if (positioned.packet.deleted_length == 0) {
        CrdtLineItemPoints points;
    }
} [[name("CrdtLineItem Packet"), color("b8bb26")]];

struct GlyphRect {
    u8 rect_length_sig;
    u32 rect_length;
    u8 unknown_byte;
    double x;
    double y;
    double width;
    double height;
    
    if (is_len_sig(rect_length_sig)) {
    } else {
        break;
    }
} [[color("b16286")]];

struct CrdtGlyphItemValue {
    u8 length_sig;
    u32 length;
    u8 unknown_byte_1;
    
    u8 color_sig;
    u32 color;
    Text text;
    GlyphRect rect;
    
    u8 first_sig;
    ID first;
    u8 last_sig;
    u8 unknown_byte_2;
    ID last;
    u8 include_last_id_sig;
    u8 unknown_byte_3;
    u8 include_last_id;
    
    if (is_len_sig(length_sig) && is_u32_sig(color_sig) &&
        is_id_sig(first_sig) && is_id_sig(last_sig) &&
        is_u8_sig(include_last_id_sig)) {
    } else {
        break;
    }
};

struct CrdtGlyphItem {
    PositionedChildPacket positioned;
    
     if (positioned.packet.deleted_length == 0) {
        CrdtGlyphItemValue value;
    }
} [[name("CrdtGlyphItem Packet"), color("d3869b")]];

struct Packet {
    PacketHeader header;
    
     match (header.type) {
        (PacketType::Uuid): UuidPacket packet;
        (PacketType::Migration): MigrationInfo packet;
        (PacketType::Stats): PageStats packet;
        (PacketType::Scene): SceneInfo packet;
        (PacketType::TreeMove): SceneTreeMove packet;
        (PacketType::TextItem): TextPacket packet;
        (PacketType::TreeNode): {
            SceneTreeNode packet;
            if (sizeof(packet) < header.length) {
                SceneTreeNodeAnchor anchor;
            }
            }
        (PacketType::GroupItem): CrdtGroupItem packet;
        (PacketType::LineItem): CrdtLineItem packet;
        (PacketType::GlyphItem): CrdtGlyphItem packet;
        (_): break;
     }
};

struct ReMarkablePage {
    Header header;
    Packet packets[while(!std::mem::eof())];
};

ReMarkablePage page @ 0x00;