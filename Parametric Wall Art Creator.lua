-- VECTRIC LUA SCRIPT
-- Parametric Wall Art Creator

local GADGET_NAME = "Parametric Wall Art Creator"
local GADGET_VERSION = "2.0.0"
local STRIPE_GIFT_URL = "https://buy.stripe.com/8x27sLeFEbdo8FrfDO7ok00"

local evaluate_field
local rectangle_points

local MODE_ORDER = { "Flow Field", "Topo Ridges", "Abstract Face", "Depth Map" }
local PRESET_ORDER = { "Flow Sculpture", "Dune Panel", "Face Form", "Face Depth Map", "Wave Depth Map" }
local CUT_LAYOUT_ORDER = { "Auto", "Multi Row", "Single Row", "Rotate 90" }
local PREVIEW_PLACEMENT_ORDER = { "Overlay", "Reserve Column" }
local PACKING_REPORT_ORDER = { "Detailed", "Summary" }

local DIALOG_HTML = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Parametric Wall Art Creator</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; font-size: 13px; margin: 12px; background: #f4f6f8; color: #1f2933; }
h1 { margin: 0 0 8px 0; font-size: 22px; color: #17395f; }
h3 { margin: 0 0 10px 0; font-size: 15px; color: #24476e; border-bottom: 1px solid #e5ebf1; padding-bottom: 6px; }
.card { background: #fff; border: 1px solid #d8dde6; border-radius: 10px; padding: 14px 16px; box-shadow: 0 1px 1px rgba(0,0,0,0.03); margin-bottom: 12px; }
.grid3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px 12px; }
label { display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748; }
input[type="text"], select { width: 100%; box-sizing: border-box; padding: 6px 7px; border: 1px solid #b9c3cf; border-radius: 5px; background: #fff; }
.checks { display: grid; gap: 6px; margin-top: 8px; }
.buttons { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 12px; }
.buttons input { min-width: 200px; padding: 9px 12px; border-radius: 6px; border: 1px solid #5d7da8; background: #e7eef9; font-weight: 700; cursor: pointer; }
#GiftMe { min-width: 200px !important; width: 200px !important; box-sizing: border-box; text-align: center !important; text-indent: 0 !important; padding: 9px 0 !important; }
body.rwa-busy, body.rwa-busy * { cursor: wait !important; }
#rwaBusyOverlay { display:none; position:fixed; inset:0; background:rgba(244,246,248,0.72); z-index:9999; align-items:center; justify-content:center; }
#rwaBusyOverlay.show { display:flex; }
.rwaBusyCard { background:#ffffff; border:1px solid #d8dde6; border-radius:12px; padding:18px 22px; min-width:280px; box-shadow:0 6px 24px rgba(0,0,0,0.12); text-align:center; }
.rwaSpinner { width:28px; height:28px; margin:0 auto 12px auto; border-radius:50%; border:3px solid #c7d5e6; border-top-color:#2c5d95; animation:rwaSpin 0.85s linear infinite; }
.rwaBusyText { font-weight:700; color:#24476e; }
.rwaBusySub { margin-top:6px; font-size:12px; color:#667; }
@keyframes rwaSpin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }
#rwaWarnOverlay { display:none; position:fixed; inset:0; background:rgba(31,41,51,0.22); z-index:10000; align-items:center; justify-content:center; }
#rwaWarnOverlay.show { display:flex; }
.rwaWarnCard { background:#ffffff; border:1px solid #d8dde6; border-radius:12px; padding:18px 22px; min-width:320px; max-width:520px; box-shadow:0 10px 30px rgba(0,0,0,0.18); }
.rwaWarnTitle { font-weight:800; color:#7b341e; margin-bottom:10px; font-size:17px; }
.rwaWarnText { color:#2d3748; line-height:1.45; white-space:pre-wrap; }
.rwaWarnActions { margin-top:14px; text-align:right; }
.rwaWarnActions button { min-width:88px; padding:8px 14px; border-radius:6px; border:1px solid #b57b61; background:#f8e3d9; font-weight:700; cursor:pointer; }
.micro { margin-top: 8px; color: #667; font-size: 12px; line-height: 1.35; }
.live { background: #f7fafc; border: 1px solid #dbe5ee; border-radius: 8px; padding: 10px 11px; line-height: 1.45; }
.full { grid-column: 1 / -1; }
</style>
</head>
<body>
<div class="card">
  <h1>Parametric Wall Art Creator</h1>
  </div>
<div class="card">
  <h3>Panel and Relief</h3>
  <div class="grid3">
    <div><label>Panel Width</label><input id="PanelWidth" name="PanelWidth" type="text"></div>
    <div><label>Panel Height</label><input id="PanelHeight" name="PanelHeight" type="text"></div>
    <div><label>Margin</label><input id="Margin" name="Margin" type="text"></div>
    <div><label>Rib Count</label><input id="RibCount" name="RibCount" type="text"></div>
    <div><label>Samples Per Rib</label><input id="SampleCount" name="SampleCount" type="text"></div>
    <div><label>Clamp Margin</label><input id="SheetMargin" name="SheetMargin" type="text"></div>
    <div><label>Base Relief</label><input id="BaseRelief" name="BaseRelief" type="text"></div>
    <div><label>Max Relief</label><input id="MaxRelief" name="MaxRelief" type="text"></div>
    <div><label>Depth Wiggle Scale</label><input id="PreviewScale" name="PreviewScale" type="text"></div>
    <div><label>Part Gap</label><input id="PartGap" name="PartGap" type="text"></div>
    <div><label>Rail Height</label><input id="RailHeight" name="RailHeight" type="text"></div>
    <div><label>Preview Thumb Fraction</label><input id="PreviewThumbFraction" name="PreviewThumbFraction" type="text"></div>
    <div><label>Layout Gap</label><input id="LayoutGap" name="LayoutGap" type="text"></div>
    <div><label>ID Height</label><input id="IdHeight" name="IdHeight" type="text"></div>
    <div><label>Relief Mode</label><select id="Mode" name="Mode"></select></div>
    <div><label>Cut Layout Mode</label><select id="CutLayoutMode" name="CutLayoutMode"></select></div>
    <div><label>Preview Placement</label><select id="PreviewPlacement" name="PreviewPlacement"></select></div>
    <div><label>Packing Report</label><select id="PackingReportLevel" name="PackingReportLevel"></select></div>
    <div class="full"><label>Preset</label><select id="BuiltinPreset" name="BuiltinPreset"></select></div>
  </div>
  <div class="checks">
    <label><input id="UseNamedLayers" name="UseNamedLayers" type="checkbox"> Route output to RWA_* layers (fallback to active layer if unavailable)</label>
    <label><input id="CreateBorder" name="CreateBorder" type="checkbox"> Create preview frame / panel outline</label>
    <label><input id="CreatePreview" name="CreatePreview" type="checkbox"> Create assembled preview on RWA_Preview</label>
    <label><input id="CreateSlatLayout" name="CreateSlatLayout" type="checkbox"> Create flat slat layout for CNC cutting</label>
    <label><input id="CreateBacker" name="CreateBacker" type="checkbox"> Create backer part layout</label>
    <label><input id="CreateGuideRails" name="CreateGuideRails" type="checkbox"> Create guide rails with rib slots</label>
    <label><input id="CreateRegistration" name="CreateRegistration" type="checkbox"> Create registration / alignment marks</label>
    <label><input id="NumberSlats" name="NumberSlats" type="checkbox"> Add engraved slat IDs on cut parts</label>
    <label><input id="NumberPreview" name="NumberPreview" type="checkbox"> Add matching slat IDs on assembly preview</label>
    <label><input id="PaginateSheets" name="PaginateSheets" type="checkbox"> Put overflow parts onto additional sheet layers instead of dropping them</label>
    <label><input id="UseFullMaterialForParts" name="UseFullMaterialForParts" type="checkbox"> Use full material area for cut parts (preview does not reserve sheet width)</label>
    <label><input id="ReservePreviewOnCutSheet" name="ReservePreviewOnCutSheet" type="checkbox"> Reserve preview thumbnail space on the cut sheet</label>
    <label><input id="SeparatePartSheets" name="SeparatePartSheets" type="checkbox"> Start separate sheet sequences for slats, backers, and rails</label>
  </div>
</div>
<div class="card">
  <h3>Depth Map Input</h3>
  <div class="grid3">
    <div class="full"><label>Depth Map Path (optional, CSV or ASCII PGM / P2)</label><input id="DepthMapPath" name="DepthMapPath" type="text"></div>
    <input id="BusySignal" name="BusySignal" type="text" style="display:none" value="0">
    <input id="WarnSignal" name="WarnSignal" type="text" style="display:none" value="0">
    <input id="WarnTitle" name="WarnTitle" type="text" style="display:none" value="">
    <input id="WarnText" name="WarnText" type="text" style="display:none" value="">
    <div><input class="LuaButton" id="ChooseDepthMap" name="ChooseDepthMap" type="button" value="Choose Depth Map"></div>
  </div>
  <div class="checks">
    <label><input id="InvertDepthMap" name="InvertDepthMap" type="checkbox"> Invert depth map</label>
  </div>
  <div class="buttons">
    <input class="LuaButton" id="GenerateGeometry" name="GenerateGeometry" type="button" value="Generate Geometry">
    <input class="LuaButton" id="Open3DPreview" name="Open3DPreview" type="button" value="Open 3D Preview" onmousedown="rwaBusyPreview()" onclick="rwaBusyPreview()">
    <input class="LuaButton" id="GenerateToolpaths" name="GenerateToolpaths" type="button" value="Generate Toolpaths" onmousedown="rwaBusyToolpaths()" onclick="return rwaBusyToolpaths();">
    <input class="LuaButton" id="GiftMe" name="GiftMe" type="button" value="Gift Me!" onmousedown="rwaBusyGift()" onclick="return rwaBusyGift();" style="min-width:200px; width:200px; box-sizing:border-box; text-align:center; text-indent:0; padding:9px 0;">
  </div>
</div>
<div id="rwaBusyOverlay">
  <div class="rwaBusyCard">
    <div class="rwaSpinner"></div>
    <div id="rwaBusyTextView" class="rwaBusyText">Generating 3D preview…</div>
    <div id="rwaBusySubView" class="rwaBusySub">Please wait while the preview model is built.</div>
  </div>

</div>
<div id="rwaWarnOverlay">
  <div class="rwaWarnCard">
    <div id="rwaWarnTitleView" class="rwaWarnTitle">Warning</div>
    <div id="rwaWarnTextView" class="rwaWarnText"></div>
    <div class="rwaWarnActions"><button type="button" onclick="rwaDismissWarning()">OK</button></div>
  </div>
</div>
<script>
(function(){
  var resetTimer = null;
  var pollTimer = null;
  function clearBusy() {
    try {
      var overlay = document.getElementById('rwaBusyOverlay');
      var textView = document.getElementById('rwaBusyTextView');
      var subView = document.getElementById('rwaBusySubView');
      if (overlay) overlay.className = '';
      if (textView) textView.textContent = 'Generating 3D preview…';
      if (subView) subView.textContent = 'Please wait while the preview model is built.';
      if (document.body) {
        document.body.className = document.body.className.replace(/rwa-busy/g, '').replace(/\s+/g, ' ').replace(/^\s|\s$/g, '');
      }
      var signal = document.getElementById('BusySignal');
      if (signal) signal.value = '0';
    } catch(e) {}
  }
  function showBusy(message, submessage, timeoutMs) {
    try {
      var overlay = document.getElementById('rwaBusyOverlay');
      var signal = document.getElementById('BusySignal');
      var textView = document.getElementById('rwaBusyTextView');
      var subView = document.getElementById('rwaBusySubView');
      if (signal) signal.value = '1';
      if (textView) textView.textContent = message || 'Working…';
      if (subView) subView.textContent = submessage || '';
      if (overlay) overlay.className = 'show';
      if (document.body) document.body.className = (document.body.className ? document.body.className + ' ' : '') + 'rwa-busy';
      if (resetTimer) window.clearTimeout(resetTimer);
      resetTimer = window.setTimeout(function(){
        if (pollTimer) {
          try { window.clearInterval(pollTimer); } catch(e) {}
          pollTimer = null;
        }
        clearBusy();
      }, timeoutMs || 20000);
    } catch(e) {}
  }
  function startPolling() {
    try {
      if (pollTimer) window.clearInterval(pollTimer);
      pollTimer = window.setInterval(function(){
        try {
          var signal = document.getElementById('BusySignal');
          var value = signal ? String(signal.value || '0') : '0';
          if (value !== '1') {
            if (pollTimer) {
              window.clearInterval(pollTimer);
              pollTimer = null;
            }
            clearBusy();
          }
        } catch(e) {}
      }, 120);
    } catch(e) {}
  }
  window.rwaBusyPreview = function(){
    try {
      showBusy('Generating 3D preview…', 'Please wait while the preview model is built.', 20000);
      startPolling();
    } catch(e) {}
    return true;
  };
  window.rwaBusyGift = function(){
    try {
      showBusy('Opening secure checkout…', 'Please wait while the payment page is launched.', 8000);
    } catch(e) {}
    return true;
  };
  window.rwaBusyToolpaths = function(){
    try {
      showBusy('Opening toolpath session…', 'Please wait while the toolpath dialog is prepared.', 5000);
    } catch(e) {}
    return true;
  };
  function syncWarningFromFields() {
    try {
      var signal = document.getElementById('WarnSignal');
      var titleField = document.getElementById('WarnTitle');
      var textField = document.getElementById('WarnText');
      var overlay = document.getElementById('rwaWarnOverlay');
      var titleView = document.getElementById('rwaWarnTitleView');
      var textView = document.getElementById('rwaWarnTextView');
      if (!signal || !overlay || !titleView || !textView) return;
      if (String(signal.value || '0') === '1') {
        titleView.textContent = String((titleField && titleField.value) || 'Warning');
        textView.textContent = String((textField && textField.value) || '');
        overlay.className = 'show';
      } else {
        overlay.className = '';
      }
    } catch(e) {}
  }
  window.rwaDismissWarning = function(){
    try {
      var overlay = document.getElementById('rwaWarnOverlay');
      var signal = document.getElementById('WarnSignal');
      if (signal) signal.value = '0';
      if (overlay) overlay.className = '';
    } catch(e) {}
    return true;
  };
  try { window.setInterval(syncWarningFromFields, 120); } catch(e) {}
  window.rwaClearBusyPreview = function(){
    try {
      if (resetTimer) window.clearTimeout(resetTimer);
      resetTimer = null;
      if (pollTimer) {
        window.clearInterval(pollTimer);
        pollTimer = null;
      }
      clearBusy();
    } catch(e) {}
    return true;
  };
})();
</script>
</body>
</html>
]]


local g_job = nil
local g_toolpath_session_running = false
local g_script_path = ""
local BUILTIN_FACE_SENTINEL = "[Built-in Face Example]"
local BUILTIN_WAVE_SENTINEL = "[Built-in Wave Example]"
local INCH_TO_MM = 25.4
local DEFAULT_PRESET_NAME = "Flow Sculpture"

local function shallow_copy_table(src)
  local dst = {}
  local k
  for k, v in pairs(src or {}) do dst[k] = v end
  return dst
end

local function job_uses_mm(job)
  return job ~= nil and job.Exists and job.InMM
end

local function unit_scale_for_job(job)
  if job_uses_mm(job) then return INCH_TO_MM end
  return 1.0
end

local function from_inch(job, value)
  return (tonumber(value) or 0.0) * unit_scale_for_job(job)
end

local function current_unit_label(job)
  if job_uses_mm(job) then return "mm" end
  return "in"
end

local function ensure_supported_job(job)
  if job == nil or not job.Exists then
    DisplayMessageBox("Open or create a job first.")
    return false
  end
  return true
end

local function min_clamp_margin(job)
  return from_inch(job, 0.75)
end

local function preview_thickness_default(job)
  return from_inch(job, 0.75)
end

local function preview_thickness_min(job)
  return from_inch(job, 0.25)
end

local function preview_thickness_max(job)
  return from_inch(job, 2.50)
end

local function make_default_options(job)
  local scale = unit_scale_for_job(job)
  return {
    panel_width = 48.0 * scale,
    panel_height = 24.0 * scale,
    margin = 1.0 * scale,
    rib_count = 64,
    sample_count = 120,
    sheet_margin = 0.75 * scale,
    layout_gap = 1.0 * scale,
    base_relief = 0.5 * scale,
    max_relief = 3.0 * scale,
    preview_scale = 0.9,
    preview_thumb_fraction = 0.32,
    id_height = 0.28 * scale,
    part_gap = 0.75 * scale,
    rail_height = 0.75 * scale,
    cut_layout_mode = "Auto",
    preview_placement = "Overlay",
    packing_report_level = "Detailed",
    mode = "Flow Field",
    builtin_preset = DEFAULT_PRESET_NAME,
    use_named_layers = true,
    create_border = true,
    create_preview = true,
    create_slat_layout = true,
    create_backer = true,
    create_guide_rails = true,
    create_registration = true,
    number_slats = true,
    number_preview = true,
    paginate_sheets = true,
    use_full_material_for_parts = true,
    reserve_preview_on_cut_sheet = false,
    separate_part_sheets = false,
    depth_map_path = "",
    invert_depth_map = false
  }
end

local function build_presets(job)
  local scale = unit_scale_for_job(job)
  return {
    ["Flow Sculpture"] = { panel_width = 48.0 * scale, panel_height = 24.0 * scale, margin = 1.0 * scale, rib_count = 64, sample_count = 140, sheet_margin = 0.75 * scale, layout_gap = 1.0 * scale, base_relief = 0.55 * scale, max_relief = 3.25 * scale, preview_scale = 0.9, preview_thumb_fraction = 0.32, id_height = 0.28 * scale, part_gap = 0.75 * scale, rail_height = 0.75 * scale, mode = "Flow Field", create_border = true, create_preview = true, create_slat_layout = true, create_backer = true, create_guide_rails = true, create_registration = true },
    ["Dune Panel"]     = { panel_width = 48.0 * scale, panel_height = 24.0 * scale, margin = 1.0 * scale, rib_count = 58, sample_count = 130, sheet_margin = 0.75 * scale, layout_gap = 1.0 * scale, base_relief = 0.45 * scale, max_relief = 2.50 * scale, preview_scale = 0.85, preview_thumb_fraction = 0.32, id_height = 0.28 * scale, part_gap = 0.75 * scale, rail_height = 0.70 * scale, mode = "Topo Ridges", create_border = true, create_preview = true, create_slat_layout = true, create_backer = true, create_guide_rails = true, create_registration = true },
    ["Face Form"]      = { panel_width = 36.0 * scale, panel_height = 48.0 * scale, margin = 1.0 * scale, rib_count = 72, sample_count = 160, sheet_margin = 0.75 * scale, layout_gap = 1.0 * scale, base_relief = 0.55 * scale, max_relief = 3.75 * scale, preview_scale = 0.95, preview_thumb_fraction = 0.32, id_height = 0.28 * scale, part_gap = 0.75 * scale, rail_height = 0.85 * scale, mode = "Abstract Face", create_border = true, create_preview = true, create_slat_layout = true, create_backer = true, create_guide_rails = true, create_registration = true },
    ["Face Depth Map"] = { panel_width = 36.0 * scale, panel_height = 48.0 * scale, margin = 1.0 * scale, rib_count = 72, sample_count = 160, sheet_margin = 0.75 * scale, layout_gap = 1.0 * scale, base_relief = 0.50 * scale, max_relief = 3.85 * scale, preview_scale = 0.98, preview_thumb_fraction = 0.32, id_height = 0.28 * scale, part_gap = 0.75 * scale, rail_height = 0.85 * scale, mode = "Depth Map", create_border = true, create_preview = true, create_slat_layout = true, create_backer = true, create_guide_rails = true, create_registration = true, depth_map_path = BUILTIN_FACE_SENTINEL, invert_depth_map = false },
    ["Wave Depth Map"] = { panel_width = 48.0 * scale, panel_height = 24.0 * scale, margin = 1.0 * scale, rib_count = 72, sample_count = 150, sheet_margin = 0.75 * scale, layout_gap = 1.0 * scale, base_relief = 0.48 * scale, max_relief = 3.20 * scale, preview_scale = 0.96, preview_thumb_fraction = 0.32, id_height = 0.28 * scale, part_gap = 0.75 * scale, rail_height = 0.80 * scale, mode = "Depth Map", create_border = true, create_preview = true, create_slat_layout = true, create_backer = true, create_guide_rails = true, create_registration = true, depth_map_path = BUILTIN_WAVE_SENTINEL, invert_depth_map = false }
  }
end

local g_depth_map = nil
local g_options = make_default_options(nil)
local PRESETS = build_presets(nil)

local function reset_unit_state(job)
  PRESETS = build_presets(job)
  g_options = make_default_options(job)
end

local function clamp(v, lo, hi)
 if v < lo then return lo elseif v > hi then return hi else return v end end
local function lerp(a, b, t) return a + ((b - a) * t) end
local function safe_max(a, b) if a > b then return a else return b end end
local function safe_min(a, b) if a < b then return a else return b end end
local function smoothstep(e0, e1, x)
  local t
  if e1 == e0 then return 0.0 end
  t = clamp((x - e0) / (e1 - e0), 0.0, 1.0)
  return t * t * (3.0 - 2.0 * t)
end
local function atan2(y, x)
  if math.atan2 ~= nil then return math.atan2(y, x) end
  if x > 0 then return math.atan(y / x) end
  if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
  if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
  if x == 0 and y > 0 then return math.pi / 2 end
  if x == 0 and y < 0 then return -math.pi / 2 end
  return 0
end
local function gaussian2(x, y, cx, cy, sx, sy)
  local dx = (x - cx) / sx
  local dy = (y - cy) / sy
  return math.exp(-0.5 * ((dx * dx) + (dy * dy)))
end
local function make_point(x, y) return { x = x, y = y } end
local function trim(s) if s == nil then return "" end return (string.gsub(s, "^%s*(.-)%s*$", "%1")) end
local function normalize_selected_path(path)
  local s = tostring(path or "")
  s = trim(s)
  if #s >= 2 then
    if (s:sub(1,1) == '"' and s:sub(-1) == '"') or (s:sub(1,1) == "'" and s:sub(-1) == "'") then
      s = s:sub(2, -2)
    end
  end
  return trim(s)
end
local function lower_ext(path) local ext = string.match(tostring(path or ""), "%.([^%.\\/]+)$") if ext == nil then return "" end return string.lower(ext) end
local function normalize_dir_path(path) local normalized = trim(path) normalized = string.gsub(normalized, "/", "\\") if normalized ~= "" and not string.match(normalized, "[\\/]$") then normalized = normalized .. "\\" end return normalized end
local function join_dir_file(dir_path, filename) return normalize_dir_path(dir_path) .. filename end
local function file_exists(path) local handle = io.open(path, "r") if handle ~= nil then handle:close() return true end return false end
local function split_tokens(line) local no_comments = string.gsub(line or "", "#.*$", "") local tokens = {} for token in string.gmatch(no_comments, "[^,%s]+") do tokens[#tokens + 1] = token end return tokens end
local function normalize_grid(grid)
  local min_v = nil local max_v = nil local y, x
  for y = 1, #grid do for x = 1, #grid[y] do local v = grid[y][x] if min_v == nil or v < min_v then min_v = v end if max_v == nil or v > max_v then max_v = v end end end
  if min_v == nil or max_v == nil then return nil end
  if max_v == min_v then max_v = min_v + 1.0 end
  for y = 1, #grid do for x = 1, #grid[y] do grid[y][x] = clamp((grid[y][x] - min_v) / (max_v - min_v), 0.0, 1.0) end end
  return { width = #grid[1], height = #grid, values = grid }
end
local function load_builtin_face_depth_map()
  local width = 32 local height = 48 local grid = {} local y, x
  for y = 1, height do
    local t = (y - 1) / (height - 1) local ny = (t * 2.0) - 1.0 grid[y] = {}
    for x = 1, width do
      local u = (x - 1) / (width - 1) local nx = (u * 2.0) - 1.0 local scale_x = 0.78
      local head = 0.70 * gaussian2(nx, ny, 0.0, 0.06, scale_x, 0.98)
      local nose = 0.88 * gaussian2(nx, ny, 0.0, -0.02, 0.10, 0.46)
      local cheeks = 0.20 * gaussian2(nx, ny, -0.28, -0.10, 0.20, 0.24) + 0.20 * gaussian2(nx, ny, 0.28, -0.10, 0.20, 0.24)
      local chin = 0.28 * gaussian2(nx, ny, 0.0, -0.63, 0.18, 0.12)
      local eye_sockets = -0.38 * gaussian2(nx, ny, -0.19, 0.05, 0.12, 0.08) - 0.38 * gaussian2(nx, ny, 0.19, 0.05, 0.12, 0.08)
      local mask_width = scale_x - (0.10 * (ny + 1.0))
      local silhouette = 1.0 - smoothstep(mask_width - 0.08, mask_width + 0.06, math.abs(nx))
      local base = head + nose + cheeks + chin + eye_sockets
      local v = clamp(base, 0.0, 1.15) / 1.15
      grid[y][x] = clamp(v * clamp(silhouette, 0.0, 1.0), 0.0, 1.0)
    end
  end
  return normalize_grid(grid)
end
local function load_builtin_wave_depth_map()
  local width = 48 local height = 28 local grid = {} local y, x
  for y = 1, height do
    local t = (y - 1) / (height - 1) grid[y] = {}
    for x = 1, width do
      local u = (x - 1) / (width - 1)
      local base = 0.50 + (math.sin((u * 6.0 * math.pi) + (t * 1.1 * math.pi)) * 0.22)
      local secondary = math.sin((u * 2.1 * math.pi) - (t * 3.0 * math.pi)) * 0.12
      local swell = gaussian2(u, t, 0.58, 0.52, 0.38, 0.22) * 0.16
      local fade = 0.65 + (0.35 * math.sin(t * math.pi))
      grid[y][x] = (base + secondary + swell) * fade
    end
  end
  return normalize_grid(grid)
end
local function load_csv_depth_map(path)
  local rows = {} local handle = io.open(path, "r") if handle == nil then error("Could not open depth map file:\n" .. tostring(path)) end
  for line in handle:lines() do local tokens = split_tokens(line) local row = {} local i for i = 1, #tokens do local num = tonumber(tokens[i]) if num ~= nil then row[#row + 1] = num end end if #row > 0 then rows[#rows + 1] = row end end
  handle:close() if #rows < 2 then error("Depth map CSV needs at least 2 rows of numeric data.") end return normalize_grid(rows)
end
local function load_pgm_depth_map(path)
  local handle = io.open(path, "r") local tokens = {} if handle == nil then error("Could not open depth map file:\n" .. tostring(path)) end
  for line in handle:lines() do local line_tokens = split_tokens(line) local i for i = 1, #line_tokens do tokens[#tokens + 1] = line_tokens[i] end end
  handle:close() if #tokens < 4 then error("PGM file is too short.") end if tokens[1] ~= "P2" then error("Only ASCII PGM (P2) files are supported.") end
  local width = tonumber(tokens[2]) local height = tonumber(tokens[3]) local maxval = tonumber(tokens[4]) local grid = {} local index = 5 local y, x
  if width == nil or height == nil or maxval == nil then error("Invalid PGM header.") end if width < 2 or height < 2 then error("PGM depth map must be at least 2x2.") end
  for y = 1, height do grid[y] = {} for x = 1, width do local v = tonumber(tokens[index]) if v == nil then error("Not enough pixel values in PGM file.") end grid[y][x] = v / maxval index = index + 1 end end
  return { width = width, height = height, values = grid }
end
local function load_depth_map(path) local ext = lower_ext(path) if ext == "csv" then return load_csv_depth_map(path) end if ext == "pgm" then return load_pgm_depth_map(path) end error("Unsupported depth map file type. Use CSV or ASCII PGM (P2).") end
local function sample_depth_map(map, u, v)
  local x, y, x0, y0, x1, y1 local tx, ty local a, b, c, d if map == nil then return 0.0 end
  u = clamp(u, 0.0, 1.0) v = clamp(v, 0.0, 1.0) x = u * (map.width - 1) y = v * (map.height - 1) x0 = math.floor(x) y0 = math.floor(y) x1 = safe_min(x0 + 1, map.width - 1) y1 = safe_min(y0 + 1, map.height - 1) tx = x - x0 ty = y - y0
  a = map.values[y0 + 1][x0 + 1] b = map.values[y0 + 1][x1 + 1] c = map.values[y1 + 1][x0 + 1] d = map.values[y1 + 1][x1 + 1]
  return ((a * (1.0 - tx)) + (b * tx)) * (1.0 - ty) + ((c * (1.0 - tx)) + (d * tx)) * ty
end
local function create_polyline_contour(points, close_shape) local contour = Contour(0.0) local i if #points < 2 then return contour end contour:AppendPoint(Point2D(points[1].x, points[1].y)) for i = 2, #points do contour:LineTo(Point2D(points[i].x, points[i].y)) end if close_shape then contour:LineTo(Point2D(points[1].x, points[1].y)) end return contour end
local function add_points_to_layer(layer, points, close_shape) local contour = create_polyline_contour(points, close_shape) local cad = CreateCadContour(contour) layer:AddObject(cad, true) end
local function add_band_from_centerline(layer, points, band_w)
  local half = safe_max(band_w * 0.5, 0.001)
  local poly = {}
  local i
  if #points < 2 then return 0 end
  for i = 1, #points do poly[#poly + 1] = make_point(points[i].x - half, points[i].y) end
  for i = #points, 1, -1 do poly[#poly + 1] = make_point(points[i].x + half, points[i].y) end
  add_points_to_layer(layer, poly, true)
  return 1
end

local function points_bounds(points)
  local min_x, min_y, max_x, max_y, i
  if #points == 0 then return 0.0, 0.0, 0.0, 0.0 end
  min_x = points[1].x min_y = points[1].y max_x = points[1].x max_y = points[1].y
  for i = 2, #points do
    if points[i].x < min_x then min_x = points[i].x end
    if points[i].y < min_y then min_y = points[i].y end
    if points[i].x > max_x then max_x = points[i].x end
    if points[i].y > max_y then max_y = points[i].y end
  end
  return min_x, min_y, max_x, max_y
end

local SEGMENT_MAP = {
  A = { make_point(0.10, 1.00), make_point(0.90, 1.00) },
  B = { make_point(0.90, 1.00), make_point(0.90, 0.50) },
  C = { make_point(0.90, 0.50), make_point(0.90, 0.00) },
  D = { make_point(0.10, 0.00), make_point(0.90, 0.00) },
  E = { make_point(0.10, 0.50), make_point(0.10, 0.00) },
  F = { make_point(0.10, 1.00), make_point(0.10, 0.50) },
  G = { make_point(0.10, 0.50), make_point(0.90, 0.50) }
}

local DIGIT_TO_SEGMENTS = {
  ["0"] = { "A", "B", "C", "D", "E", "F" },
  ["1"] = { "B", "C" },
  ["2"] = { "A", "B", "G", "E", "D" },
  ["3"] = { "A", "B", "G", "C", "D" },
  ["4"] = { "F", "G", "B", "C" },
  ["5"] = { "A", "F", "G", "C", "D" },
  ["6"] = { "A", "F", "G", "E", "C", "D" },
  ["7"] = { "A", "B", "C" },
  ["8"] = { "A", "B", "C", "D", "E", "F", "G" },
  ["9"] = { "A", "B", "C", "D", "F", "G" }
}

local function add_stroke_number(layer, text_value, cx, cy, height)
  local text = tostring(text_value or "")
  local char_w = height * 0.62
  local char_gap = height * 0.22
  local total_w = (#text * char_w) + (safe_max(#text - 1, 0) * char_gap)
  local start_x = cx - (total_w * 0.5)
  local i, j
  for i = 1, #text do
    local ch = string.sub(text, i, i)
    local segs = DIGIT_TO_SEGMENTS[ch]
    local base_x = start_x + ((i - 1) * (char_w + char_gap))
    if segs ~= nil then
      for j = 1, #segs do
        local seg_pts = SEGMENT_MAP[segs[j]]
        add_points_to_layer(layer, {
          make_point(base_x + (seg_pts[1].x * char_w), cy + ((seg_pts[1].y - 0.5) * height)),
          make_point(base_x + (seg_pts[2].x * char_w), cy + ((seg_pts[2].y - 0.5) * height))
        }, false)
      end
    end
  end
  return #text
end
rectangle_points = function(x0, y0, x1, y1) return { make_point(x0, y0), make_point(x1, y0), make_point(x1, y1), make_point(x0, y1) } end
local function translate_points(points, dx, dy) local out = {} local i for i = 1, #points do out[#out + 1] = make_point(points[i].x + dx, points[i].y + dy) end return out end
local function rotate_points_90(points, min_x, min_y, max_x, max_y)
  local out = {} local i
  for i = 1, #points do
    local local_x = points[i].x - min_x
    local local_y = points[i].y - min_y
    out[#out + 1] = make_point(local_y, (max_x - min_x) - local_x)
  end
  return out
end
local function signed_soft_normalize(x, drive)
  local k = drive or 1.0
  local pos = math.exp(x * k)
  local neg = math.exp(-x * k)
  local shaped = (pos - neg) / (pos + neg)
  local max_pos = math.exp(0.80 * k)
  local max_neg = math.exp(-0.80 * k)
  local max_shaped = (max_pos - max_neg) / (max_pos + max_neg)
  if math.abs(max_shaped) < 1.0e-6 then return clamp(x / 0.80, -1.0, 1.0) end
  return clamp(shaped / max_shaped, -1.0, 1.0)
end
local function positive_soft_normalize(x, drive, reference)
  local k = drive or 1.0
  local ref = reference or 1.0
  local xv = safe_max(x, 0.0)
  local shaped = 1.0 - math.exp(-xv * k)
  local denom = 1.0 - math.exp(-safe_max(ref, 1.0e-6) * k)
  if math.abs(denom) < 1.0e-6 then return clamp(xv / safe_max(ref, 1.0e-6), 0.0, 1.0) end
  return clamp(shaped / denom, 0.0, 1.0)
end
local function field_value_flow(nx, ny)
  local r = math.sqrt((nx * nx) + (ny * ny))
  local theta = atan2(ny, nx)
  local center_fade = smoothstep(0.12, 0.34, r)
  local outer_swirl = 0.72 * math.sin(theta * 2.1 + (r * 5.8))
  local center_waves = 0.30 * math.sin((nx * math.pi * 2.8) + (ny * 1.1))
  local center_bands = 0.18 * math.cos((ny * math.pi * 2.4) - (nx * 0.9))
  local outer_waves = 0.42 * math.sin((nx * math.pi * 3.8) + (outer_swirl * center_fade))
  local outer_bands = 0.26 * math.cos((ny * math.pi * 4.6) - (nx * 1.7))
  local waves = lerp(center_waves, outer_waves, center_fade)
  local bands = lerp(center_bands, outer_bands, center_fade)
  local combined = signed_soft_normalize((waves * 0.70) + (bands * 0.55), 1.22)
  local center_soften = 1.0 - smoothstep(0.00, 0.24, r)
  local softened = lerp(combined, smoothstep(-1.0, 1.0, combined) * 2.0 - 1.0, center_soften * 0.35)
  return clamp(0.5 + (softened * 0.5), 0.0, 1.0)
end
local function field_value_topo(nx, ny)
  local ridge_phase = (nx * 5.2 * math.pi) + (ny * 4.0)
  local ridge = 1.0 - math.abs(math.sin(ridge_phase))
  local ridge_shaped = ridge * ridge
  local dune = 0.5 + (0.5 * math.cos(ny * math.pi * 2.2))
  return clamp((ridge_shaped * 0.82) + (dune * 0.18), 0.0, 1.0)
end
local function sample_relief_for_rib(u_center, t)
  local ny = (t * 2.0) - 1.0
  if g_options.mode ~= "Topo Ridges" and g_options.mode ~= "Flow Field" and g_options.mode ~= "Abstract Face" then
    local nx = (u_center * 2.0) - 1.0
    return evaluate_field(nx, ny, t)
  end
  local rib_span = 1.0 / safe_max(g_options.rib_count, 1)
  local offsets = { -0.36, -0.18, 0.0, 0.18, 0.36 }
  local weights = { 0.10, 0.20, 0.40, 0.20, 0.10 }
  local weighted = 0.0
  local peak = 0.0
  local j
  for j = 1, #offsets do
    local sample_u = clamp(u_center + (offsets[j] * rib_span), 0.0, 1.0)
    local sample_nx = (sample_u * 2.0) - 1.0
    local sample_v = evaluate_field(sample_nx, ny, t)
    weighted = weighted + (sample_v * weights[j])
    if sample_v > peak then peak = sample_v end
  end
  if g_options.mode == "Flow Field" then
    local smoothed = clamp(weighted, 0.0, 1.0)
    return clamp((smoothed * 0.90) + (smoothstep(0.0, 1.0, smoothed) * 0.10), 0.0, 1.0)
  elseif g_options.mode == "Abstract Face" then
    local smoothed = clamp(weighted, 0.0, 1.0)
    return clamp((smoothed * 0.94) + (smoothstep(0.0, 1.0, smoothed) * 0.06), 0.0, 1.0)
  end
  return clamp((weighted * 0.75) + (peak * 0.25), 0.0, 1.0)
end
local function field_value_face(nx, ny)
  local scale_x = 0.78
  local head = 0.70 * gaussian2(nx, ny, 0.0, 0.06, scale_x, 0.98)
  local nose = 0.88 * gaussian2(nx, ny, 0.0, -0.02, 0.10, 0.46)
  local cheeks = 0.20 * gaussian2(nx, ny, -0.28, -0.10, 0.20, 0.24) + 0.20 * gaussian2(nx, ny, 0.28, -0.10, 0.20, 0.24)
  local chin = 0.28 * gaussian2(nx, ny, 0.0, -0.63, 0.18, 0.12)
  local eye_sockets = -0.38 * gaussian2(nx, ny, -0.19, 0.05, 0.12, 0.08) - 0.38 * gaussian2(nx, ny, 0.19, 0.05, 0.12, 0.08)
  local mask_width = scale_x - (0.10 * (ny + 1.0))
  local silhouette = 1.0 - smoothstep(mask_width - 0.08, mask_width + 0.06, math.abs(nx))
  local base = head + nose + cheeks + chin + eye_sockets
  local softened = positive_soft_normalize(base, 0.92, 1.72)
  local center_fade = gaussian2(nx, ny, 0.0, -0.04, 0.20, 0.42)
  local v = lerp(softened, smoothstep(0.0, 1.0, softened), center_fade * 0.04)
  return clamp(v * clamp(silhouette, 0.0, 1.0), 0.0, 1.0)
end
evaluate_field = function(nx, ny, t)
  local edge_dist_x = 1.0 - math.abs(nx) local edge_dist_y = 1.0 - math.abs(ny) local edge = safe_min(edge_dist_x, edge_dist_y) local fade = smoothstep(0.0, 0.18, edge) local v
  if g_options.mode == "Flow Field" then v = field_value_flow(nx, ny)
  elseif g_options.mode == "Topo Ridges" then v = field_value_topo(nx, ny)
  elseif g_options.mode == "Abstract Face" then v = field_value_face(nx, ny)
  else local u = (nx + 1.0) * 0.5 local vv = 1.0 - t if g_depth_map == nil then return 0.0 end v = sample_depth_map(g_depth_map, u, vv) if g_options.invert_depth_map then v = 1.0 - v end end
  return clamp(v * fade, 0.0, 1.0)
end
local function build_rib_preview_and_profile(preview_x, preview_y, preview_w, preview_h, rib_index, preview_depth_scale)
  local points_preview = {}
  local points_profile_front = {}
  local i
  local samples = safe_max(g_options.sample_count, 20)
  local u = (rib_index + 0.5) / g_options.rib_count
  local center = g_options.base_relief + (g_options.max_relief * 0.5)
  local relief_values = {}

  for i = 0, samples do
    local t = i / samples
    relief_values[i + 1] = sample_relief_for_rib(u, t)
  end

  if g_options.mode == "Flow Field" and samples >= 4 then
    local smooth_passes = 2
    local pass
    for pass = 1, smooth_passes do
      local smoothed = {}
      smoothed[1] = clamp((relief_values[1] * 0.78) + (relief_values[2] * 0.22), 0.0, 1.0)
      for i = 2, samples do
        local prev_v = relief_values[i - 1]
        local curr_v = relief_values[i]
        local next_v = relief_values[i + 1]
        smoothed[i] = clamp((prev_v * 0.18) + (curr_v * 0.64) + (next_v * 0.18), 0.0, 1.0)
      end
      smoothed[samples + 1] = clamp((relief_values[samples + 1] * 0.78) + (relief_values[samples] * 0.22), 0.0, 1.0)
      relief_values = smoothed
    end
  end

  for i = 0, samples do
    local t = i / samples
    local y_preview = preview_y + (t * preview_h)
    local v = relief_values[i + 1]
    local depth = g_options.base_relief + (g_options.max_relief * v)
    local offset = (depth - center) * preview_depth_scale
    points_preview[#points_preview + 1] = make_point(preview_x + (u * preview_w) + offset, y_preview)
    points_profile_front[#points_profile_front + 1] = make_point(depth, t * g_options.panel_height)
  end
  return points_preview, points_profile_front
end
local function build_slat_outline(profile_front) local outline = {} local i outline[#outline + 1] = make_point(0.0, 0.0) outline[#outline + 1] = make_point(profile_front[1].x, 0.0) for i = 1, #profile_front do outline[#outline + 1] = make_point(profile_front[i].x, profile_front[i].y) end outline[#outline + 1] = make_point(0.0, g_options.panel_height) return outline end

local function load_effective_depth_map_and_source()
  local path = normalize_selected_path(g_options.depth_map_path)
  local source_text = ""
  if g_options.mode ~= "Depth Map" then
    g_depth_map = nil
    return nil, source_text
  end
  if path == "" then
    if g_options.builtin_preset == "Wave Depth Map" then path = BUILTIN_WAVE_SENTINEL else path = BUILTIN_FACE_SENTINEL end
  end
  if path == BUILTIN_FACE_SENTINEL then
    g_depth_map = load_builtin_face_depth_map()
    source_text = BUILTIN_FACE_SENTINEL
  elseif path == BUILTIN_WAVE_SENTINEL then
    g_depth_map = load_builtin_wave_depth_map()
    source_text = BUILTIN_WAVE_SENTINEL
  else
    g_depth_map = load_depth_map(path)
    source_text = path
  end
  return g_depth_map, source_text
end

local function build_preview_export_data()
  local slats = {}
  local i, sample_idx
  local panel_w = g_options.panel_width
  local panel_h = g_options.panel_height
  local pitch = panel_w / g_options.rib_count
  local face_w = pitch * 0.88
  local gap = pitch - face_w
  local source_text = "Procedural"
  local map_loaded = nil
  if g_options.mode == "Depth Map" then
    map_loaded, source_text = load_effective_depth_map_and_source()
    if map_loaded == nil then error("Unable to load depth map for preview export.") end
  else
    g_depth_map = nil
    source_text = g_options.mode
  end
  for i = 0, g_options.rib_count - 1 do
    local _, profile_front = build_rib_preview_and_profile(0.0, 0.0, panel_w, panel_h, i, 1.0)
    local prof = {}
    for sample_idx = 1, #profile_front do
      prof[#prof + 1] = { depth = profile_front[sample_idx].x, y = profile_front[sample_idx].y }
    end
    slats[#slats + 1] = {
      index = i + 1,
      x = ((i + 0.5) / g_options.rib_count) * panel_w,
      width = face_w,
      gap = gap,
      profile = prof
    }
  end
  return {
    name = GADGET_NAME,
    version = GADGET_VERSION,
    mode = g_options.mode,
    source = source_text,
    panel_width = panel_w,
    panel_height = panel_h,
    rib_count = g_options.rib_count,
    base_relief = g_options.base_relief,
    max_relief = g_options.max_relief,
    slat_pitch = pitch,
    unit_label = current_unit_label(g_job),
    default_slat_thickness = preview_thickness_default(g_job),
    min_slat_thickness = preview_thickness_min(g_job),
    max_slat_thickness = preview_thickness_max(g_job),
    preview_depth_padding = preview_thickness_default(g_job),
    slats = slats
  }
end

local function js_string(s)
  local out = tostring(s or "")
  out = out:gsub('\\', '\\\\')
  out = out:gsub('"', '\\"')
  out = out:gsub('\r', '\\r')
  out = out:gsub('\n', '\\n')
  return '"' .. out .. '"'
end

local function js_number(n)
  return string.format('%.6f', tonumber(n) or 0)
end

local function build_preview_data_js(data)
  local parts = {}
  local i, j
  parts[#parts + 1] = '{'
  parts[#parts + 1] = 'name:' .. js_string(data.name) .. ','
  parts[#parts + 1] = 'version:' .. js_string(data.version) .. ','
  parts[#parts + 1] = 'mode:' .. js_string(data.mode) .. ','
  parts[#parts + 1] = 'source:' .. js_string(data.source) .. ','
  parts[#parts + 1] = 'panelWidth:' .. js_number(data.panel_width) .. ','
  parts[#parts + 1] = 'panelHeight:' .. js_number(data.panel_height) .. ','
  parts[#parts + 1] = 'ribCount:' .. tostring(data.rib_count) .. ','
  parts[#parts + 1] = 'baseRelief:' .. js_number(data.base_relief) .. ','
  parts[#parts + 1] = 'maxRelief:' .. js_number(data.max_relief) .. ','
  parts[#parts + 1] = 'slatPitch:' .. js_number(data.slat_pitch) .. ','
  parts[#parts + 1] = 'unitLabel:' .. js_string(data.unit_label) .. ','
  parts[#parts + 1] = 'defaultSlatThickness:' .. js_number(data.default_slat_thickness) .. ','
  parts[#parts + 1] = 'minSlatThickness:' .. js_number(data.min_slat_thickness) .. ','
  parts[#parts + 1] = 'maxSlatThickness:' .. js_number(data.max_slat_thickness) .. ','
  parts[#parts + 1] = 'previewDepthPadding:' .. js_number(data.preview_depth_padding) .. ','
  parts[#parts + 1] = 'slats:['
  for i = 1, #data.slats do
    local slat = data.slats[i]
    parts[#parts + 1] = '{index:' .. tostring(slat.index) .. ',x:' .. js_number(slat.x) .. ',width:' .. js_number(slat.width) .. ',gap:' .. js_number(slat.gap) .. ',profile:['
    for j = 1, #slat.profile do
      local p = slat.profile[j]
      parts[#parts + 1] = '{depth:' .. js_number(p.depth) .. ',y:' .. js_number(p.y) .. '}'
      if j < #slat.profile then parts[#parts + 1] = ',' end
    end
    parts[#parts + 1] = ']}'
    if i < #data.slats then parts[#parts + 1] = ',' end
  end
  parts[#parts + 1] = ']}'
  return table.concat(parts)
end

local function build_threejs_preview_html(data)
  local data_js = build_preview_data_js(data)
  return [[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Parametric Wall Art Creator 3D Preview</title>
<style>
html, body { margin:0; padding:0; width:100%; height:100%; overflow:hidden; background:#0f1115; color:#eef2f7; font-family:Segoe UI, Arial, sans-serif; }
#wrap { position:fixed; inset:0; display:grid; grid-template-columns: 300px 1fr; }
#sidebar { padding:16px 18px; background:#171b22; border-right:1px solid #2a3340; overflow:auto; }
#viewport { position:relative; }
canvas { display:block; }
h1 { margin:0 0 10px 0; font-size:22px; }
.small { color:#b8c0cc; line-height:1.45; font-size:13px; }
.kv { margin:14px 0; display:grid; grid-template-columns: 120px 1fr; gap:6px 10px; font-size:13px; }
.controls { margin-top:18px; display:grid; gap:10px; }
label { display:grid; gap:6px; font-size:13px; color:#dbe3ee; }
input[type=range] { width:100%; }
button { padding:8px 10px; border-radius:8px; border:1px solid #4d6482; background:#243243; color:#eef2f7; cursor:pointer; }
#errorBox { margin-top:14px; padding:10px; border:1px solid #7a3d3d; background:#2a1717; color:#ffcccc; display:none; white-space:pre-wrap; font-size:12px; line-height:1.35; }
#statusBox { margin-top:14px; padding:10px; border:1px solid #33465f; background:#182230; color:#d5e5f7; white-space:pre-wrap; font-size:12px; line-height:1.35; }
#progressOuter { margin-top:10px; height:10px; border:1px solid #33465f; background:#101822; border-radius:999px; overflow:hidden; }
#progressInner { width:0%; height:100%; background:#8db5e6; transition: width 120ms ease; }
</style>
</head>
<body>
<div id="wrap">
  <div id="sidebar">
    <h1>Parametric Wall Art Creator</h1>
    <div class="small">Interactive 3D preview of the assembled slats. Drag in the viewport to orbit. Shift-drag or right-drag to pan. Use the mouse wheel to zoom.</div>
    <div class="kv">
      <div>Mode</div><div id="mode"></div>
      <div>Source</div><div id="source"></div>
      <div>Panel</div><div id="panel"></div>
      <div>Ribs</div><div id="ribs"></div>
      <div>Depth</div><div id="depth"></div>
    </div>
    <div class="controls">
      <label>Vertical exaggeration <input id="exag" type="range" min="0.5" max="2.5" step="0.05" value="1.0"></label>
      <label>Slat thickness <input id="thickness" type="range" min="0.25" max="2.5" step="0.05" value="0.75"></label>
      <label>Material gap <input id="gap" type="range" min="0.0" max="0.25" step="0.005" value="0.02"></label>
      <button id="isoView">Isometric view</button>
      <button id="frontView">Front view</button>
      <button id="backView">Back view</button>
      <button id="sideView">Side view</button>
      <button id="flipModel">Flip front/back</button>
    </div>
    <div id="statusBox">Preparing 3D preview...</div>
    <div id="progressOuter"><div id="progressInner"></div></div>
    <div id="errorBox"></div>
  </div>
  <div id="viewport"></div>
</div>
<script>const modelData = ]] .. data_js .. [[;</script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script>
(function(){
  const errorBox = document.getElementById('errorBox');
  const statusBox = document.getElementById('statusBox');
  const progressInner = document.getElementById('progressInner');
  function setStatus(msg, pct) {
    statusBox.textContent = String(msg || 'Working...');
    if (progressInner && typeof pct === 'number') {
      const clamped = Math.max(0, Math.min(100, pct));
      progressInner.style.width = clamped + '%';
    }
  }
  function showError(msg) {
    errorBox.style.display = 'block';
    errorBox.textContent = String(msg || 'Unknown preview error');
    setStatus('Preview failed to initialize.', 100);
  }
  try {
    setStatus('Loading Three.js library...', 8);
    if (!window.THREE) {
      showError('Three.js failed to load. This preview needs internet access the first time it loads the library from jsDelivr.');
      return;
    }
    setStatus('Initializing 3D scene...', 18);
    const viewport = document.getElementById('viewport');
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x0f1115);
    const camera = new THREE.PerspectiveCamera(38, Math.max(1, viewport.clientWidth) / Math.max(1, viewport.clientHeight), 0.1, 5000);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(window.devicePixelRatio || 1);
    renderer.setSize(Math.max(1, viewport.clientWidth), Math.max(1, viewport.clientHeight));
    viewport.appendChild(renderer.domElement);

    setStatus('Adding lights and surfaces...', 30);
    const ambient = new THREE.AmbientLight(0xffffff, 0.9); scene.add(ambient);
    const dir1 = new THREE.DirectionalLight(0xffffff, 1.1); dir1.position.set(120, 180, 160); scene.add(dir1);
    const dir2 = new THREE.DirectionalLight(0xaac7ff, 0.45); dir2.position.set(-140, 60, -120); scene.add(dir2);

    const floor = new THREE.Mesh(
      new THREE.PlaneGeometry(Math.max(1, modelData.panelWidth * 1.8), Math.max(1, modelData.panelHeight * 1.8)),
      new THREE.MeshPhongMaterial({ color:0x1b212b, side:THREE.DoubleSide })
    );
    floor.rotation.x = -Math.PI / 2;
    floor.position.y = -0.25;
    scene.add(floor);

    const wall = new THREE.Mesh(
      new THREE.PlaneGeometry(Math.max(1, modelData.panelWidth * 1.2), Math.max(1, modelData.panelHeight * 1.2)),
      new THREE.MeshPhongMaterial({ color:0x202733, side:THREE.DoubleSide })
    );
    wall.position.set(0, modelData.panelHeight * 0.5, -0.02);
    scene.add(wall);

    const artGroup = new THREE.Group();
    scene.add(artGroup);
    const panelLeft = -modelData.panelWidth / 2;
    const material = new THREE.MeshStandardMaterial({ color:0xd8c7a1, roughness:0.72, metalness:0.04 });

    function safeProfileY(p, fallback) {
      const v = (p && typeof p.y === 'number') ? p.y : fallback;
      return isFinite(v) ? v : fallback;
    }
    function safeProfileDepth(p) {
      const v = (p && typeof p.depth === 'number') ? p.depth : 0;
      return isFinite(v) ? v : 0;
    }
    function makeSlatMesh(slat, exaggeration, thickness, gapFactor) {
      const profile = Array.isArray(slat.profile) ? slat.profile : [];
      if (!profile.length) return null;
      const shape = new THREE.Shape();
      shape.moveTo(0, 0);
      shape.lineTo(safeProfileDepth(profile[0]) * exaggeration, 0);
      for (let i = 0; i < profile.length; i++) {
        const p = profile[i];
        shape.lineTo(safeProfileDepth(p) * exaggeration, safeProfileY(p, 0));
      }
      shape.lineTo(0, modelData.panelHeight);
      shape.lineTo(0, 0);
      const actualWidth = Math.max(0.05, (slat.width || modelData.slatPitch || modelData.defaultSlatThickness) * (1 - gapFactor));
      const extrudeSettings = { depth: actualWidth, bevelEnabled: false, steps: 1 };
      const geometry = new THREE.ExtrudeGeometry(shape, extrudeSettings);
      geometry.rotateY(Math.PI / 2);
      const mesh = new THREE.Mesh(geometry, material);
      mesh.position.x = panelLeft + (slat.x || 0) - (actualWidth * 0.5);
      mesh.position.y = 0;
      mesh.position.z = 0;
      mesh.scale.z = Math.max(0.1, thickness / Math.max(0.0001, modelData.defaultSlatThickness));
      return mesh;
    }

    function rebuild() {
      setStatus('Building slats from current settings...', 58);
      while (artGroup.children.length) {
        const c = artGroup.children.pop();
        if (c.geometry) c.geometry.dispose();
        artGroup.remove(c);
      }
      const exag = parseFloat(document.getElementById('exag').value) || 1.0;
      const thickness = parseFloat(document.getElementById('thickness').value) || modelData.defaultSlatThickness;
      const gap = parseFloat(document.getElementById('gap').value) || 0.02;
      let added = 0;
      (modelData.slats || []).forEach((slat) => {
        const mesh = makeSlatMesh(slat, exag, thickness, gap);
        if (mesh) {
          artGroup.add(mesh);
          added += 1;
        }
      });
      setStatus('3D preview ready. Slats rendered: ' + added + '\nMode: ' + modelData.mode + '\nSource: ' + modelData.source, 100);
      if (added === 0) {
        showError('No slats were embedded in the preview export. Try generating geometry first, then open the 3D preview again.');
      }
    }

    const FIT_MARGIN = 2.2;
    const FRONT_BACK_EXTRA = 1.75;
    const SIDE_EXTRA = 1.55;
    const ISO_EXTRA = 1.65;
    const DEFAULT_DEPTH = Math.max(1, modelData.maxRelief + modelData.previewDepthPadding);
    function fitRadiusForExtents(width, height, depth, phi) {
      const safeHeight = Math.max(1, height);
      const safeWidth = Math.max(1, width);
      const safeDepth = Math.max(1, depth);
      const verticalFov = THREE.MathUtils.degToRad(camera.fov || 38);
      const aspect = Math.max(1e-6, viewport.clientWidth / Math.max(1, viewport.clientHeight));
      const horizontalFov = 2 * Math.atan(Math.tan(verticalFov / 2) * aspect);
      const verticalDistance = (safeHeight * 0.5) / Math.tan(verticalFov * 0.5);
      const horizontalDistance = (safeWidth * 0.5) / Math.tan(horizontalFov * 0.5);
      const base = Math.max(verticalDistance, horizontalDistance);
      const depthAllowance = safeDepth * Math.max(0.25, Math.abs(Math.sin(phi)));
      return (base + depthAllowance) * FIT_MARGIN;
    }
    const orbit = { radius: fitRadiusForExtents(modelData.panelWidth, modelData.panelHeight, DEFAULT_DEPTH, 1.05), theta: Math.PI / 4, phi: 1.05, targetX: 0, targetY: modelData.panelHeight * 0.5, targetZ: -0.8 };
    let modelFlipped = false;
    function applyCamera() {
      const sinPhi = Math.sin(orbit.phi);
      camera.position.set(
        orbit.targetX + orbit.radius * sinPhi * Math.sin(orbit.theta),
        orbit.targetY + orbit.radius * Math.cos(orbit.phi),
        orbit.targetZ + orbit.radius * sinPhi * Math.cos(orbit.theta)
      );
      camera.lookAt(orbit.targetX, orbit.targetY, orbit.targetZ);
    }
    function viewTheta(kind) {
      const frontTheta = modelFlipped ? 0.0 : Math.PI;
      const backTheta = modelFlipped ? Math.PI : 0.0;
      if (kind === 'front') return frontTheta;
      if (kind === 'back') return backTheta;
      if (kind === 'side') return Math.PI / 2;
      return Math.PI / 4;
    }
    function setView(kind) {
      if (kind === 'front') {
        orbit.theta = viewTheta('front');
        orbit.phi = Math.PI / 2;
        orbit.radius = fitRadiusForExtents(modelData.panelWidth, modelData.panelHeight, DEFAULT_DEPTH, orbit.phi) * FRONT_BACK_EXTRA;
      } else if (kind === 'back') {
        orbit.theta = viewTheta('back');
        orbit.phi = Math.PI / 2;
        orbit.radius = fitRadiusForExtents(modelData.panelWidth, modelData.panelHeight, DEFAULT_DEPTH, orbit.phi) * FRONT_BACK_EXTRA;
      } else if (kind === 'side') {
        orbit.theta = viewTheta('side');
        orbit.phi = 1.1;
        orbit.radius = fitRadiusForExtents(DEFAULT_DEPTH, modelData.panelHeight, modelData.panelWidth, orbit.phi) * SIDE_EXTRA;
      } else {
        orbit.theta = viewTheta('iso');
        orbit.phi = 1.05;
        orbit.radius = fitRadiusForExtents(modelData.panelWidth + DEFAULT_DEPTH, modelData.panelHeight, DEFAULT_DEPTH, orbit.phi) * ISO_EXTRA;
      }
      applyCamera();
    }
    function flipModelView() {
      modelFlipped = !modelFlipped;
      setView('front');
      setStatus('3D preview ready. Slats rendered: ' + artGroup.children.length + '\nMode: ' + modelData.mode + '\nSource: ' + modelData.source + '\nFront/back flipped: ' + (modelFlipped ? 'yes' : 'no'), 100);
    }

    let dragging = false;
    let panMode = false;
    let lastX = 0, lastY = 0;
    renderer.domElement.addEventListener('contextmenu', (e) => e.preventDefault());
    renderer.domElement.addEventListener('mousedown', (e) => {
      dragging = true;
      panMode = (e.button === 2) || e.shiftKey;
      lastX = e.clientX; lastY = e.clientY;
    });
    window.addEventListener('mouseup', () => { dragging = false; panMode = false; });
    window.addEventListener('mousemove', (e) => {
      if (!dragging) return;
      const dx = e.clientX - lastX;
      const dy = e.clientY - lastY;
      lastX = e.clientX; lastY = e.clientY;
      if (panMode) {
        orbit.targetX -= dx * 0.03;
        orbit.targetY += dy * 0.03;
      } else {
        orbit.theta -= dx * 0.01;
        orbit.phi -= dy * 0.01;
        orbit.phi = Math.max(0.15, Math.min(Math.PI - 0.15, orbit.phi));
      }
      applyCamera();
    });
    renderer.domElement.addEventListener('wheel', (e) => {
      e.preventDefault();
      const factor = (e.deltaY > 0) ? 1.08 : 0.92;
      orbit.radius = Math.max(2, orbit.radius * factor);
      applyCamera();
    }, { passive: false });

    const thicknessInput = document.getElementById('thickness');
    thicknessInput.min = String(modelData.minSlatThickness);
    thicknessInput.max = String(modelData.maxSlatThickness);
    thicknessInput.step = (modelData.unitLabel === 'mm') ? '0.5' : '0.05';
    thicknessInput.value = String(modelData.defaultSlatThickness);

    document.getElementById('mode').textContent = modelData.mode;
    document.getElementById('source').textContent = modelData.source;
    document.getElementById('panel').textContent = modelData.panelWidth.toFixed(2) + ' x ' + modelData.panelHeight.toFixed(2) + ' ' + modelData.unitLabel;
    document.getElementById('ribs').textContent = String(modelData.ribCount);
    document.getElementById('depth').textContent = modelData.maxRelief.toFixed(2) + ' ' + modelData.unitLabel;
    ['exag','thickness','gap'].forEach(id => document.getElementById(id).addEventListener('input', rebuild));
    document.getElementById('isoView').addEventListener('click', () => setView('iso'));
    document.getElementById('frontView').addEventListener('click', () => setView('front'));
    document.getElementById('backView').addEventListener('click', () => setView('back'));
    document.getElementById('sideView').addEventListener('click', () => setView('side'));
    document.getElementById('flipModel').addEventListener('click', () => flipModelView());
    setStatus('Preparing camera and controls...', 82);
    function resize() {
      camera.aspect = Math.max(1, viewport.clientWidth) / Math.max(1, viewport.clientHeight);
      camera.updateProjectionMatrix();
      renderer.setSize(Math.max(1, viewport.clientWidth), Math.max(1, viewport.clientHeight));
    }
    window.addEventListener('resize', resize);
    rebuild();
    setStatus('Finalizing camera view...', 94);
    setView('front');
    renderer.setAnimationLoop(() => { renderer.render(scene, camera); });
  } catch (err) {
    showError(err && err.stack ? err.stack : String(err));
  }
})();
</script>
<div id="rwaBusyOverlay">
  <div class="rwaBusyCard">
    <div class="rwaSpinner"></div>
    <div class="rwaBusyText">Generating 3D preview…</div>
    <div class="rwaBusySub">Please wait while the preview model is built.</div>
  </div>
</div>
<script>
(function(){
  var resetTimer = null;
  window.rwaBusyPreview = function(){
    try {
      var overlay = document.getElementById('rwaBusyOverlay');
      if (overlay) overlay.className = 'show';
      if (document.body) document.body.className = (document.body.className ? document.body.className + ' ' : '') + 'rwa-busy';
      if (resetTimer) window.clearTimeout(resetTimer);
      resetTimer = window.setTimeout(function(){
        try {
          if (overlay) overlay.className = '';
          if (document.body) document.body.className = document.body.className.replace(/rwa-busy/g, '').replace(/\s+/g, ' ').replace(/^\s|\s$/g, '');
        } catch(e) {}
      }, 12000);
    } catch(e) {}
    return true;
  };
})();
</script>
</body>
</html>]]
end

local function build_gift_html()
  return [[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=https://buy.stripe.com/8x27sLeFEbdo8FrfDO7ok00">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Gift Me!</title>
<style>
html, body { margin:0; padding:0; background:#eef3f8; font-family:Segoe UI, Arial, sans-serif; color:#1f2933; }
.wrap { max-width:760px; margin:0 auto; padding:24px; }
.card { background:#ffffff; border:1px solid #d8dde6; border-radius:14px; padding:22px 24px; box-shadow:0 6px 24px rgba(0,0,0,0.08); text-align:center; }
h1 { margin:0 0 10px 0; font-size:24px; color:#17395f; }
.copy { margin:0 0 16px 0; color:#46505a; }
a.cta { display:inline-block; padding:12px 18px; border-radius:9px; background:#635bff; color:#ffffff; text-decoration:none; font-weight:700; border:1px solid #4b44d0; }
</style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>Gift Me!</h1>
      <div class="copy">Opening secure checkout…</div>
      <a class="cta" href="https://buy.stripe.com/8x27sLeFEbdo8FrfDO7ok00" target="_self">Continue</a>
    </div>
  </div>
</body>
</html>]]
end

local function write_text_file(path, content)
  local f = io.open(path, 'w')
  if f == nil then return false end
  f:write(content)
  f:close()
  return true
end

local function open_in_browser(path)
  local p = tostring(path or '')
  if p == '' then return false end
  local file_url = 'file:///' .. p:gsub('\\', '/'):gsub(' ', '%%20')
  local cmd_url = 'cmd /c start "" "' .. file_url .. '"'
  local ok = os.execute(cmd_url)
  if ok == nil or ok == 0 or ok == true then return ok end
  local normalized = p:gsub('/', '\\')
  local cmd_path = 'cmd /c start "" "' .. normalized .. '"'
  return os.execute(cmd_path)
end

local function open_external_url(url)
  local u = tostring(url or '')
  if u == '' then return false end
  local cmd = 'cmd /c start "" "' .. u .. '"'
  return os.execute(cmd)
end
local function bind_dialog_fields(dialog)
  local i
  dialog:AddDoubleField("PanelWidth", g_options.panel_width)
  dialog:AddDoubleField("PanelHeight", g_options.panel_height)
  dialog:AddDoubleField("Margin", g_options.margin)
  dialog:AddIntegerField("RibCount", g_options.rib_count)
  dialog:AddIntegerField("SampleCount", g_options.sample_count)
  dialog:AddDoubleField("SheetMargin", g_options.sheet_margin)
  dialog:AddDoubleField("LayoutGap", g_options.layout_gap)
  dialog:AddDoubleField("BaseRelief", g_options.base_relief)
  dialog:AddDoubleField("MaxRelief", g_options.max_relief)
  dialog:AddDoubleField("PreviewScale", g_options.preview_scale)
  dialog:AddDoubleField("PreviewThumbFraction", g_options.preview_thumb_fraction)
  dialog:AddDoubleField("IdHeight", g_options.id_height)
  dialog:AddDoubleField("PartGap", g_options.part_gap)
  dialog:AddDoubleField("RailHeight", g_options.rail_height)
  dialog:AddDropDownList("Mode", g_options.mode) for i = 1, #MODE_ORDER do dialog:AddDropDownListValue("Mode", MODE_ORDER[i]) end
  dialog:AddDropDownList("CutLayoutMode", g_options.cut_layout_mode) for i = 1, #CUT_LAYOUT_ORDER do dialog:AddDropDownListValue("CutLayoutMode", CUT_LAYOUT_ORDER[i]) end
  dialog:AddDropDownList("PreviewPlacement", g_options.preview_placement) for i = 1, #PREVIEW_PLACEMENT_ORDER do dialog:AddDropDownListValue("PreviewPlacement", PREVIEW_PLACEMENT_ORDER[i]) end
  dialog:AddDropDownList("PackingReportLevel", g_options.packing_report_level) for i = 1, #PACKING_REPORT_ORDER do dialog:AddDropDownListValue("PackingReportLevel", PACKING_REPORT_ORDER[i]) end
  dialog:AddDropDownList("BuiltinPreset", g_options.builtin_preset) for i = 1, #PRESET_ORDER do dialog:AddDropDownListValue("BuiltinPreset", PRESET_ORDER[i]) end
  dialog:AddCheckBox("UseNamedLayers", g_options.use_named_layers)
  dialog:AddCheckBox("CreateBorder", g_options.create_border)
  dialog:AddCheckBox("CreatePreview", g_options.create_preview)
  dialog:AddCheckBox("CreateSlatLayout", g_options.create_slat_layout)
  dialog:AddCheckBox("CreateBacker", g_options.create_backer)
  dialog:AddCheckBox("CreateGuideRails", g_options.create_guide_rails)
  dialog:AddCheckBox("CreateRegistration", g_options.create_registration)
  dialog:AddCheckBox("NumberSlats", g_options.number_slats)
  dialog:AddCheckBox("NumberPreview", g_options.number_preview)
  dialog:AddCheckBox("PaginateSheets", g_options.paginate_sheets)
  dialog:AddCheckBox("UseFullMaterialForParts", g_options.use_full_material_for_parts)
  dialog:AddCheckBox("ReservePreviewOnCutSheet", g_options.reserve_preview_on_cut_sheet)
  dialog:AddCheckBox("SeparatePartSheets", g_options.separate_part_sheets)
  dialog:AddTextField("DepthMapPath", g_options.depth_map_path)
  dialog:AddTextField("BusySignal", "0")
  dialog:AddTextField("WarnSignal", "0")
  dialog:AddTextField("WarnTitle", "")
  dialog:AddTextField("WarnText", "")
  dialog:AddCheckBox("InvertDepthMap", g_options.invert_depth_map)
end
local function refresh_hint(dialog)
  return
end
local function pull_options_from_dialog(dialog)
  g_options.panel_width = dialog:GetDoubleField("PanelWidth") g_options.panel_height = dialog:GetDoubleField("PanelHeight") g_options.margin = dialog:GetDoubleField("Margin") g_options.rib_count = dialog:GetIntegerField("RibCount") g_options.sample_count = dialog:GetIntegerField("SampleCount") g_options.sheet_margin = dialog:GetDoubleField("SheetMargin") g_options.layout_gap = dialog:GetDoubleField("LayoutGap") g_options.base_relief = dialog:GetDoubleField("BaseRelief") g_options.max_relief = dialog:GetDoubleField("MaxRelief") g_options.preview_scale = dialog:GetDoubleField("PreviewScale") g_options.preview_thumb_fraction = dialog:GetDoubleField("PreviewThumbFraction") g_options.id_height = dialog:GetDoubleField("IdHeight") g_options.part_gap = dialog:GetDoubleField("PartGap") g_options.rail_height = dialog:GetDoubleField("RailHeight") g_options.mode = dialog:GetDropDownListValue("Mode") g_options.cut_layout_mode = dialog:GetDropDownListValue("CutLayoutMode") g_options.preview_placement = dialog:GetDropDownListValue("PreviewPlacement") g_options.packing_report_level = dialog:GetDropDownListValue("PackingReportLevel") g_options.builtin_preset = dialog:GetDropDownListValue("BuiltinPreset") g_options.use_named_layers = dialog:GetCheckBox("UseNamedLayers") g_options.create_border = dialog:GetCheckBox("CreateBorder") g_options.create_preview = dialog:GetCheckBox("CreatePreview") g_options.create_slat_layout = dialog:GetCheckBox("CreateSlatLayout") g_options.create_backer = dialog:GetCheckBox("CreateBacker") g_options.create_guide_rails = dialog:GetCheckBox("CreateGuideRails") g_options.create_registration = dialog:GetCheckBox("CreateRegistration") g_options.number_slats = dialog:GetCheckBox("NumberSlats") g_options.number_preview = dialog:GetCheckBox("NumberPreview") g_options.paginate_sheets = dialog:GetCheckBox("PaginateSheets") g_options.use_full_material_for_parts = dialog:GetCheckBox("UseFullMaterialForParts") g_options.reserve_preview_on_cut_sheet = dialog:GetCheckBox("ReservePreviewOnCutSheet") g_options.separate_part_sheets = dialog:GetCheckBox("SeparatePartSheets") g_options.depth_map_path = normalize_selected_path(dialog:GetTextField("DepthMapPath")) g_options.invert_depth_map = dialog:GetCheckBox("InvertDepthMap")
end
local function push_options_to_dialog(dialog)
  dialog:UpdateDoubleField("PanelWidth", g_options.panel_width) dialog:UpdateDoubleField("PanelHeight", g_options.panel_height) dialog:UpdateDoubleField("Margin", g_options.margin) dialog:UpdateIntegerField("RibCount", g_options.rib_count) dialog:UpdateIntegerField("SampleCount", g_options.sample_count) dialog:UpdateDoubleField("SheetMargin", g_options.sheet_margin) dialog:UpdateDoubleField("LayoutGap", g_options.layout_gap) dialog:UpdateDoubleField("BaseRelief", g_options.base_relief) dialog:UpdateDoubleField("MaxRelief", g_options.max_relief) dialog:UpdateDoubleField("PreviewScale", g_options.preview_scale) dialog:UpdateDoubleField("PreviewThumbFraction", g_options.preview_thumb_fraction) dialog:UpdateDoubleField("IdHeight", g_options.id_height) dialog:UpdateDoubleField("PartGap", g_options.part_gap) dialog:UpdateDoubleField("RailHeight", g_options.rail_height) dialog:UpdateDropDownListValue("Mode", g_options.mode) dialog:UpdateDropDownListValue("CutLayoutMode", g_options.cut_layout_mode) dialog:UpdateDropDownListValue("PreviewPlacement", g_options.preview_placement) dialog:UpdateDropDownListValue("PackingReportLevel", g_options.packing_report_level) dialog:UpdateDropDownListValue("BuiltinPreset", g_options.builtin_preset) dialog:UpdateCheckBox("UseNamedLayers", g_options.use_named_layers) dialog:UpdateCheckBox("CreateBorder", g_options.create_border) dialog:UpdateCheckBox("CreatePreview", g_options.create_preview) dialog:UpdateCheckBox("CreateSlatLayout", g_options.create_slat_layout) dialog:UpdateCheckBox("CreateBacker", g_options.create_backer) dialog:UpdateCheckBox("CreateGuideRails", g_options.create_guide_rails) dialog:UpdateCheckBox("CreateRegistration", g_options.create_registration) dialog:UpdateCheckBox("NumberSlats", g_options.number_slats) dialog:UpdateCheckBox("NumberPreview", g_options.number_preview) dialog:UpdateCheckBox("PaginateSheets", g_options.paginate_sheets) dialog:UpdateCheckBox("UseFullMaterialForParts", g_options.use_full_material_for_parts) dialog:UpdateCheckBox("ReservePreviewOnCutSheet", g_options.reserve_preview_on_cut_sheet) dialog:UpdateCheckBox("SeparatePartSheets", g_options.separate_part_sheets) dialog:UpdateTextField("DepthMapPath", g_options.depth_map_path) dialog:UpdateCheckBox("InvertDepthMap", g_options.invert_depth_map) refresh_hint(dialog)
end
local function apply_preset(name)
  local preset = PRESETS[name] local keep_named = g_options.use_named_layers local keep_path = g_options.depth_map_path local keep_layout = g_options.cut_layout_mode local keep_preview_placement = g_options.preview_placement local keep_report = g_options.packing_report_level local keep_full_material = g_options.use_full_material_for_parts local keep_reserve_preview = g_options.reserve_preview_on_cut_sheet local keep_separate_parts = g_options.separate_part_sheets local k if preset == nil then return end
  for k, v in pairs(preset) do g_options[k] = v end g_options.use_named_layers = keep_named g_options.cut_layout_mode = keep_layout g_options.preview_placement = keep_preview_placement g_options.packing_report_level = keep_report g_options.use_full_material_for_parts = keep_full_material g_options.reserve_preview_on_cut_sheet = keep_reserve_preview g_options.separate_part_sheets = keep_separate_parts g_options.builtin_preset = name
  if name == "Face Depth Map" then g_options.depth_map_path = BUILTIN_FACE_SENTINEL
  elseif name == "Wave Depth Map" then g_options.depth_map_path = BUILTIN_WAVE_SENTINEL
  elseif trim(keep_path) ~= "" then g_options.depth_map_path = keep_path end
end
local function validate_options(job)
  local clamp_margin_floor = min_clamp_margin(job)
  if g_options.sheet_margin < clamp_margin_floor then g_options.sheet_margin = clamp_margin_floor end
  if g_options.panel_width <= 0.0 or g_options.panel_height <= 0.0 then return false, "Panel width and height must be > 0." end
  if g_options.rib_count < 4 then return false, "Rib count must be at least 4." end
  if g_options.sample_count < 16 then return false, "Samples per rib must be at least 16." end
  if g_options.max_relief <= 0.0 then return false, "Max relief must be greater than zero." end
  if g_options.rail_height <= 0.0 then return false, "Rail height must be greater than zero." end
  if g_options.preview_thumb_fraction <= 0.05 or g_options.preview_thumb_fraction >= 0.95 then return false, "Preview thumb fraction should be between 0.05 and 0.95." end
  if g_options.id_height <= 0.0 then return false, "ID height must be greater than zero." end
  if g_options.cut_layout_mode ~= "Auto" and g_options.cut_layout_mode ~= "Multi Row" and g_options.cut_layout_mode ~= "Single Row" and g_options.cut_layout_mode ~= "Rotate 90" then return false, "Unsupported cut layout mode." end
  if g_options.preview_placement ~= "Overlay" and g_options.preview_placement ~= "Reserve Column" then return false, "Unsupported preview placement mode." end
  if job ~= nil and (g_options.sheet_margin * 2.0 >= job.Width or g_options.sheet_margin * 2.0 >= job.Height) then return false, "Sheet margin leaves no usable material area." end
  if g_options.mode == "Depth Map" then local path = normalize_selected_path(g_options.depth_map_path) if path == "" then if g_options.builtin_preset == "Wave Depth Map" then g_options.depth_map_path = BUILTIN_WAVE_SENTINEL path = BUILTIN_WAVE_SENTINEL else g_options.depth_map_path = BUILTIN_FACE_SENTINEL path = BUILTIN_FACE_SENTINEL end end if path ~= BUILTIN_FACE_SENTINEL and path ~= BUILTIN_WAVE_SENTINEL and not file_exists(path) then return false, "Depth map file not found:\n" .. tostring(path) end end
  if not g_options.create_preview and not g_options.create_slat_layout and not g_options.create_border and not g_options.create_backer and not g_options.create_guide_rails and not g_options.create_registration then return false, "Enable at least one output." end
  return true, ""
end
local function try_get_layer(layer_manager, name)
  local ok, res
  if layer_manager == nil then return nil end
  if layer_manager.GetLayerWithName ~= nil then
    ok, res = pcall(function() return layer_manager:GetLayerWithName(name) end)
    if ok and res ~= nil then return res end
  end
  if layer_manager.FindLayerWithName ~= nil then
    ok, res = pcall(function() return layer_manager:FindLayerWithName(name) end)
    if ok and res ~= nil then return res end
  end
  if layer_manager.CreateLayerWithName ~= nil then
    ok, res = pcall(function() return layer_manager:CreateLayerWithName(name) end)
    if ok and res ~= nil then return res end
  end
  if layer_manager.AddLayer ~= nil then
    ok, res = pcall(function() return layer_manager:AddLayer(name) end)
    if ok and res ~= nil then return res end
  end
  if layer_manager.GetLayerWithName ~= nil then
    ok, res = pcall(function() return layer_manager:GetLayerWithName(name, true) end)
    if ok and res ~= nil then return res end
  end
  return nil
end

local function resolve_output_layer(job, active_layer, name)
  local layer
  if not g_options.use_named_layers then return active_layer, false end
  layer = try_get_layer(job.LayerManager, name)
  if layer == nil then return active_layer, false end
  pcall(function() layer.Locked = false end)
  return layer, true
end

local function set_layer_visible(layer, is_visible)
  if layer == nil then return end
  pcall(function() layer.Visible = is_visible end)
  pcall(function() layer.IsVisible = is_visible end)
end

local function set_layer_color(layer, red, green, blue)
  if layer == nil then return end
  pcall(function()
    if layer.SetColour ~= nil then
      layer:SetColour(red, green, blue)
    elseif layer.SetColor ~= nil then
      layer:SetColor(red, green, blue)
    end
  end)
end

local function add_registration_ticks(layer, x0, y0, x1, y1, tick_len)
  local cx = (x0 + x1) * 0.5 local cy = (y0 + y1) * 0.5
  add_points_to_layer(layer, { make_point(cx - tick_len, y0), make_point(cx + tick_len, y0) }, false)
  add_points_to_layer(layer, { make_point(cx - tick_len, y1), make_point(cx + tick_len, y1) }, false)
  add_points_to_layer(layer, { make_point(x0, cy - tick_len), make_point(x0, cy + tick_len) }, false)
  add_points_to_layer(layer, { make_point(x1, cy - tick_len), make_point(x1, cy + tick_len) }, false)
  return 4
end
local function add_backer_geometry(layer, x0, y0) local x1 = x0 + g_options.panel_width local y1 = y0 + g_options.panel_height add_points_to_layer(layer, rectangle_points(x0, y0, x1, y1), true) return 1, x0, y0, x1, y1 end
local function add_rail_with_slots_and_xs(rail_layer, mark_layer, x0, y0, rail_length, rail_height, rib_pitch)
  local rail_count = 0
  local mark_count = 0
  local i
  local slot_width = clamp(rib_pitch * 0.55, 0.05, rib_pitch * 0.9)
  local x_size = safe_min(slot_width, rail_height) * 0.32
  local cy = y0 + (rail_height * 0.5)
  add_points_to_layer(rail_layer, rectangle_points(x0, y0, x0 + rail_length, y0 + rail_height), true)
  rail_count = rail_count + 1
  for i = 0, g_options.rib_count - 1 do
    local cx = x0 + ((i + 0.5) * rib_pitch)
    local sx0 = cx - (slot_width * 0.5)
    local sx1 = cx + (slot_width * 0.5)
    add_points_to_layer(rail_layer, rectangle_points(sx0, y0, sx1, y0 + rail_height), true)
    rail_count = rail_count + 1
    if mark_layer ~= nil then
      add_points_to_layer(mark_layer, { make_point(cx - x_size, cy - x_size), make_point(cx + x_size, cy + x_size) }, false)
      add_points_to_layer(mark_layer, { make_point(cx - x_size, cy + x_size), make_point(cx + x_size, cy - x_size) }, false)
      mark_count = mark_count + 2
    end
  end
  return rail_count, mark_count
end
local function generate_geometry(job)
  local active_layer = job.LayerManager:GetActiveLayer()
  local object_count = 0
  local omitted_parts = 0
  local used_named = false
  local used_fallback = false
  local preview_overlay = false
  local source_text = ""
  local preview_rib_count = 0
  local front_preview_band_count = 0
  local slat_part_count = 0
  local slat_id_count = 0
  local preview_id_count = 0
  local backer_part_count = 0
  local rail_part_count = 0
  local rail_mark_count = 0
  local effective_sheet_margin = safe_max(g_options.sheet_margin, min_clamp_margin(g_job))
  local sheet_x0 = job.MinX + effective_sheet_margin
  local sheet_y0 = job.MinY + effective_sheet_margin
  local sheet_x1 = (job.MinX + job.Width) - effective_sheet_margin
  local sheet_y1 = (job.MinY + job.Height) - effective_sheet_margin
  local cut_x0 = sheet_x0
  local cut_y0 = sheet_y0
  local cut_x1 = sheet_x1
  local cut_y1 = sheet_y1
  local preview_scale = 1.0
  local preview_w = 0.0
  local preview_h = 0.0
  local preview_x = sheet_x0
  local preview_y = sheet_y0
  local preview_box_pad = g_options.part_gap * 2.0
  local front_band_w = 0.0
  local border_x0, border_y0, border_x1, border_y1
  local border_layer, border_named = nil, false
  local preview_layer, preview_named = nil, false
  local front_preview_layer, front_preview_named = nil, false
  local preview_id_layer, preview_id_named = nil, false
  local reg_preview_layer, reg_preview_named = nil, false
  local slat_defs = {}
  local slat_width_min = nil
  local slat_width_max = nil
  local total_part_area = 0.0
  local total_slat_area = 0.0
  local total_backer_area = 0.0
  local total_rail_area = 0.0
  local slat_layout_mode_used = g_options.cut_layout_mode
  local slat_sheet_requirement = 1
  local slat_fit_capacity = 0
  local slat_unplaceable_count = 0
  local slat_warning_text = ""
  local part_family_stats = {}
  if active_layer == nil then error("No active layer available.") end
  if g_options.mode == "Depth Map" then
    local path = trim(g_options.depth_map_path)
    if path == "" then path = BUILTIN_FACE_SENTINEL end
    if path == BUILTIN_FACE_SENTINEL then g_depth_map = load_builtin_face_depth_map()
    elseif path == BUILTIN_WAVE_SENTINEL then g_depth_map = load_builtin_wave_depth_map()
    else g_depth_map = load_depth_map(path) end
    source_text = path
  else
    g_depth_map = nil
  end
  border_layer, border_named = resolve_output_layer(job, active_layer, "RWA_Border")
  preview_layer, preview_named = resolve_output_layer(job, active_layer, "RWA_Preview")
  front_preview_layer, front_preview_named = resolve_output_layer(job, active_layer, "RWA_FrontPreview")
  preview_id_layer, preview_id_named = resolve_output_layer(job, active_layer, "RWA_Assembly_IDs")
  reg_preview_layer, reg_preview_named = resolve_output_layer(job, active_layer, "RWA_Registration")
  used_named = border_named or preview_named or front_preview_named or preview_id_named or reg_preview_named
  if g_options.use_named_layers and not (border_named and preview_named and front_preview_named and preview_id_named and reg_preview_named) then used_fallback = true end

  if g_options.create_preview or g_options.create_border or g_options.number_preview then
    preview_scale = safe_min((job.Width * g_options.preview_thumb_fraction) / g_options.panel_width, (job.Height * g_options.preview_thumb_fraction) / g_options.panel_height)
    preview_scale = clamp(preview_scale, 0.10, 1.0)
    preview_w = g_options.panel_width * preview_scale
    preview_h = g_options.panel_height * preview_scale
    if g_options.preview_placement == "Reserve Column" and (not g_options.use_full_material_for_parts) and g_options.reserve_preview_on_cut_sheet then
      local reserve_w = preview_w + preview_box_pad * 2.0 + safe_max(g_options.max_relief * g_options.preview_scale * preview_scale, 0.0)
      if (sheet_x1 - sheet_x0 - reserve_w) >= (g_options.max_relief + g_options.base_relief + g_options.part_gap) then
        local reserve_x0
        local reserve_x1
        cut_x1 = sheet_x1 - reserve_w
        reserve_x0 = cut_x1
        reserve_x1 = sheet_x1
        preview_x = reserve_x0 + ((reserve_x1 - reserve_x0 - preview_w) * 0.5)
        preview_y = sheet_y0 + ((sheet_y1 - sheet_y0 - preview_h) * 0.5)
      else
        preview_overlay = true
        preview_x = sheet_x0 + ((sheet_x1 - sheet_x0 - preview_w) * 0.5)
        preview_y = sheet_y0 + ((sheet_y1 - sheet_y0 - preview_h) * 0.5)
      end
    else
      preview_overlay = true
      preview_x = sheet_x0 + ((sheet_x1 - sheet_x0 - preview_w) * 0.5)
      preview_y = sheet_y0 + ((sheet_y1 - sheet_y0 - preview_h) * 0.5)
    end
    front_band_w = safe_max((preview_w / safe_max(g_options.rib_count, 1)) * 0.82, 0.01)
    border_x0 = preview_x - preview_box_pad
    border_y0 = preview_y - preview_box_pad
    border_x1 = preview_x + preview_w + preview_box_pad
    border_y1 = preview_y + preview_h + preview_box_pad
  end

  local usable_w = cut_x1 - cut_x0
  local usable_h = cut_y1 - cut_y0
  local usable_area = usable_w * usable_h

  local function ensure_family_stat(family)
    if part_family_stats[family] == nil then
      part_family_stats[family] = {
        sheet_count = 1,
        states = { [1] = { cursor_x = cut_x0, cursor_y = cut_y0, shelf_h = 0.0 } },
        packed_area = 0.0,
        max_sheet_index = 1
      }
    end
    return part_family_stats[family]
  end

  local function family_for_prefix(prefix)
    if not g_options.separate_part_sheets then return "GLOBAL" end
    if prefix == "RWA_Slats" or prefix == "RWA_Slat_IDs" then return "SLATS" end
    if prefix == "RWA_Backer" or prefix == "RWA_Registration" then return "BACKER" end
    if prefix == "RWA_Rails" or prefix == "RWA_Rail_Xs" then return "RAILS" end
    return "GLOBAL"
  end

  local sheet_layers = {}
  local function apply_default_visibility()
    local key, layer
    local layer1
    if not g_options.use_named_layers then return end
    set_layer_visible(border_layer, false)
    set_layer_visible(preview_layer, false)
    set_layer_visible(front_preview_layer, false)
    set_layer_visible(preview_id_layer, false)
    set_layer_visible(reg_preview_layer, false)
    for key, layer in pairs(sheet_layers) do
      set_layer_visible(layer, false)
    end
    if sheet_layers["RWA_Slats_S01"] ~= nil then set_layer_visible(sheet_layers["RWA_Slats_S01"], true) end
    if sheet_layers["RWA_Slat_IDs_S01"] ~= nil then set_layer_visible(sheet_layers["RWA_Slat_IDs_S01"], true) end
    if not used_fallback then
      layer1 = try_get_layer(job.LayerManager, "Layer 1")
      if layer1 ~= nil then set_layer_visible(layer1, false) end
    end
  end
  local function sheet_suffix(index)
    return string.format("_S%02d", index)
  end
  local function get_sheet_layer(prefix, sheet_idx)
    local key = prefix .. sheet_suffix(sheet_idx)
    if sheet_layers[key] == nil then
      local layer, named = resolve_output_layer(job, active_layer, key)
      sheet_layers[key] = layer
      if named then used_named = true elseif g_options.use_named_layers then used_fallback = true end
    end
    return sheet_layers[key]
  end

  local function pack_rect_family(family, w, h, single_row)
    local stat = ensure_family_stat(family)
    local state = stat.states[stat.sheet_count]
    if w > usable_w or h > usable_h then return nil, nil, nil end
    if state.cursor_x + w > cut_x1 then
      state.cursor_x = cut_x0
      if single_row then
        state.cursor_y = cut_y1 + 1.0
      else
        state.cursor_y = state.cursor_y + state.shelf_h + g_options.part_gap
        state.shelf_h = 0.0
      end
    end
    if state.cursor_y + h > cut_y1 then
      if not g_options.paginate_sheets then return nil, nil, nil end
      stat.sheet_count = stat.sheet_count + 1
      stat.max_sheet_index = stat.sheet_count
      stat.states[stat.sheet_count] = { cursor_x = cut_x0, cursor_y = cut_y0, shelf_h = 0.0 }
      state = stat.states[stat.sheet_count]
    end
    local px = state.cursor_x
    local py = state.cursor_y
    state.cursor_x = state.cursor_x + w + g_options.part_gap
    if h > state.shelf_h then state.shelf_h = h end
    stat.packed_area = stat.packed_area + (w * h)
    return px, py, stat.sheet_count
  end

  local function simulate_capacity(widths, heights, single_row)
    local state = { sheet = 1, cursor_x = cut_x0, cursor_y = cut_y0, shelf_h = 0.0 }
    local fit = 0
    local idx
    for idx = 1, #widths do
      local w = widths[idx]
      local h = heights[idx]
      if w > usable_w or h > usable_h then return fit, 999999 end
      if state.cursor_x + w > cut_x1 then
        state.cursor_x = cut_x0
        if single_row then
          state.cursor_y = cut_y1 + 1.0
        else
          state.cursor_y = state.cursor_y + state.shelf_h + g_options.part_gap
          state.shelf_h = 0.0
        end
      end
      if state.cursor_y + h > cut_y1 then
        state.sheet = state.sheet + 1
        state.cursor_x = cut_x0
        state.cursor_y = cut_y0
        state.shelf_h = 0.0
      end
      state.cursor_x = state.cursor_x + w + g_options.part_gap
      if h > state.shelf_h then state.shelf_h = h end
      fit = fit + 1
    end
    return fit, state.sheet
  end

  local i
  for i = 0, g_options.rib_count - 1 do
    local preview_points, front_profile = build_rib_preview_and_profile(preview_x, preview_y, preview_w, preview_h, i, g_options.preview_scale * preview_scale)
    local slat_outline = build_slat_outline(front_profile)
    local min_x, min_y, max_x, max_y = points_bounds(slat_outline)
    local part_w = (max_x - min_x) + (g_options.part_gap * 0.25)
    local part_h = g_options.panel_height
    slat_defs[#slat_defs + 1] = {
      rib_index = i,
      preview_points = preview_points,
      preview_center_x = preview_x + (((i + 0.5) / g_options.rib_count) * preview_w),
      slat_outline = slat_outline,
      min_x = min_x,
      min_y = min_y,
      max_x = max_x,
      max_y = max_y,
      part_w = part_w,
      part_h = part_h
    }
    if slat_width_min == nil or part_w < slat_width_min then slat_width_min = part_w end
    if slat_width_max == nil or part_w > slat_width_max then slat_width_max = part_w end
    total_slat_area = total_slat_area + (part_w * part_h)
  end

  local normal_w = {}
  local normal_h = {}
  local rot_w = {}
  local rot_h = {}
  local function simulate_for_layout_mode(layout_mode)
    if layout_mode == "Rotate 90" then return simulate_capacity(rot_w, rot_h, false) end
    if layout_mode == "Single Row" then return simulate_capacity(normal_w, normal_h, true) end
    return simulate_capacity(normal_w, normal_h, false)
  end
  if g_options.cut_layout_mode == "Auto" then
    local normal_w, normal_h, rot_w, rot_h = {}, {}, {}, {}
    for i = 1, #slat_defs do
      normal_w[i] = slat_defs[i].part_w
      normal_h[i] = slat_defs[i].part_h
      rot_w[i] = slat_defs[i].part_h
      rot_h[i] = slat_defs[i].part_w
    end
    local fit_multi, sheets_multi = simulate_capacity(normal_w, normal_h, false)
    local fit_single, sheets_single = simulate_capacity(normal_w, normal_h, true)
    local fit_rot, sheets_rot = simulate_capacity(rot_w, rot_h, false)
    local best_mode = "Multi Row"
    local best_fit = fit_multi
    local best_sheets = sheets_multi
    if fit_rot > best_fit or (fit_rot == best_fit and sheets_rot < best_sheets) then best_mode = "Rotate 90" best_fit = fit_rot best_sheets = sheets_rot end
    if fit_single > best_fit or (fit_single == best_fit and sheets_single < best_sheets) then best_mode = "Single Row" best_fit = fit_single best_sheets = sheets_single end
    slat_layout_mode_used = best_mode
  else
    slat_layout_mode_used = g_options.cut_layout_mode
  end

  if g_options.create_border and (g_options.create_preview or g_options.create_border) then
    add_points_to_layer(border_layer, rectangle_points(border_x0, border_y0, border_x1, border_y1), true)
    object_count = object_count + 1
  end

  for i = 1, #slat_defs do
    local def = slat_defs[i]
    if g_options.create_preview then
      add_points_to_layer(preview_layer, def.preview_points, false)
      object_count = object_count + 1
      preview_rib_count = preview_rib_count + 1
      object_count = object_count + add_band_from_centerline(front_preview_layer, def.preview_points, front_band_w)
      front_preview_band_count = front_preview_band_count + 1
    end
    if g_options.number_preview then
      local id_y = preview_y - (preview_box_pad * 0.45)
      if id_y <= sheet_y0 then id_y = preview_y + preview_h + (preview_box_pad * 0.25) end
      local added = add_stroke_number(preview_id_layer, tostring(def.rib_index + 1), def.preview_center_x, id_y, g_options.id_height * preview_scale)
      preview_id_count = preview_id_count + added
      object_count = object_count + added
    end
    if g_options.create_slat_layout then
      local family = family_for_prefix("RWA_Slats")
      local place_w = def.part_w
      local place_h = def.part_h
      local rotated = false
      if slat_layout_mode_used == "Rotate 90" then
        place_w = def.part_h
        place_h = def.part_w
        rotated = true
      end
      local px, py, sheet_idx = pack_rect_family(family, place_w, place_h, slat_layout_mode_used == "Single Row")
      if px == nil then
        omitted_parts = omitted_parts + 1
      else
        local layer = get_sheet_layer("RWA_Slats", sheet_idx)
        local outline_pts
        if rotated then
          outline_pts = rotate_points_90(def.slat_outline, def.min_x, def.min_y, def.max_x, def.max_y)
          outline_pts = translate_points(outline_pts, px, py)
        else
          outline_pts = translate_points(def.slat_outline, px - def.min_x, py - def.min_y)
        end
        add_points_to_layer(layer, outline_pts, true)
        object_count = object_count + 1
        slat_part_count = slat_part_count + 1
        if g_options.number_slats then
          local id_layer = get_sheet_layer("RWA_Slat_IDs", sheet_idx)
          local id_h = clamp(g_options.id_height, 0.12, safe_min(place_h * 0.12, place_w * 0.60))
          local added = add_stroke_number(id_layer, tostring(def.rib_index + 1), px + (place_w * 0.5), py + id_h * 0.9, id_h)
          slat_id_count = slat_id_count + added
          object_count = object_count + added
        end
      end
    end
  end

  if g_options.create_backer then
    local family = family_for_prefix("RWA_Backer")
    local px, py, sheet_idx = pack_rect_family(family, g_options.panel_width, g_options.panel_height, false)
    if px == nil then
      omitted_parts = omitted_parts + 1
    else
      local layer = get_sheet_layer("RWA_Backer", sheet_idx)
      local reg_layer = get_sheet_layer("RWA_Registration", sheet_idx)
      local count, bx0, by0, bx1, by1 = add_backer_geometry(layer, px, py)
      object_count = object_count + count
      backer_part_count = backer_part_count + 1
      total_backer_area = total_backer_area + (g_options.panel_width * g_options.panel_height)
      if g_options.create_registration then
        local reg_added = add_registration_ticks(reg_layer, bx0, by0, bx1, by1, safe_min(g_options.panel_width, g_options.panel_height) * 0.025)
        object_count = object_count + reg_added
      end
    end
  end

  if g_options.create_guide_rails then
    local rail_length = g_options.panel_width
    local rail_height = g_options.rail_height
    local r
    for r = 1, 2 do
      local family = family_for_prefix("RWA_Rails")
      local px, py, sheet_idx = pack_rect_family(family, rail_length, rail_height, false)
      if px == nil then
        omitted_parts = omitted_parts + 1
      else
        local layer = get_sheet_layer("RWA_Rails", sheet_idx)
        local mark_layer = get_sheet_layer("RWA_Rail_Xs", sheet_idx)
        local rail_added, mark_added = add_rail_with_slots_and_xs(layer, mark_layer, px, py, rail_length, rail_height, g_options.panel_width / g_options.rib_count)
        object_count = object_count + rail_added + mark_added
        rail_part_count = rail_part_count + 1
        rail_mark_count = rail_mark_count + mark_added
        total_rail_area = total_rail_area + (rail_length * rail_height)
        if g_options.create_registration then
          local reg_layer = get_sheet_layer("RWA_Registration", sheet_idx)
          object_count = object_count + add_registration_ticks(reg_layer, px, py, px + rail_length, py + rail_height, rail_height * 0.5)
        end
      end
    end
  end

  local total_sheet_count = 0
  local family_sheet_summary = {}
  local packed_area_sum = 0.0
  local family_name, stat
  for family_name, stat in pairs(part_family_stats) do
    total_sheet_count = total_sheet_count + stat.sheet_count
    packed_area_sum = packed_area_sum + stat.packed_area
    family_sheet_summary[#family_sheet_summary + 1] = family_name .. ":" .. tostring(stat.sheet_count)
  end
  if total_sheet_count == 0 then total_sheet_count = 1 end
  total_part_area = total_slat_area + total_backer_area + total_rail_area

  apply_default_visibility()
  if g_options.use_named_layers and sheet_layers["RWA_Slats_S01"] ~= nil then
    pcall(function() job.LayerManager:SetActiveLayer(sheet_layers["RWA_Slats_S01"]) end)
  end
  job:Refresh2DView()
  local route_text = "active layer"
  if used_named and not used_fallback then route_text = "RWA_* layers"
  elseif used_named and used_fallback then route_text = "mixed RWA_* + active layer fallback" end
  return {
    object_count = object_count,
    route_text = route_text,
    source_text = source_text,
    omitted_parts = omitted_parts,
    preview_overlay = preview_overlay,
    sheet_count = total_sheet_count,
    family_sheet_summary = table.concat(family_sheet_summary, ", "),
    preview_rib_count = preview_rib_count,
    front_preview_band_count = front_preview_band_count,
    slat_part_count = slat_part_count,
    slat_id_count = slat_id_count,
    preview_id_count = preview_id_count,
    backer_part_count = backer_part_count,
    rail_part_count = rail_part_count,
    rail_mark_count = rail_mark_count,
    slat_width_min = slat_width_min or 0.0,
    slat_width_max = slat_width_max or 0.0,
    usable_w = usable_w,
    usable_h = usable_h,
    usable_area = usable_area,
    packed_area = packed_area_sum,
    utilization_pct = (usable_area > 0.0 and total_sheet_count > 0) and ((packed_area_sum / (usable_area * total_sheet_count)) * 100.0) or 0.0,
    total_part_area = total_part_area,
    slat_layout_mode_used = slat_layout_mode_used,
    effective_sheet_margin = effective_sheet_margin,
    slat_sheet_requirement = slat_sheet_requirement,
    slat_fit_capacity = slat_fit_capacity,
    slat_unplaceable_count = slat_unplaceable_count,
    slat_warning_text = slat_warning_text
  }
end
local function clear_preview_busy(dialog)
  if dialog == nil then return end
  pcall(function() dialog:UpdateTextField("BusySignal", "0") end)
end

local find_layer_only

local function has_generated_wall_art_layers(job)
  local lm
  if job == nil or not job.Exists then return false end
  lm = job.LayerManager
  if lm == nil then return false end
  if find_layer_only(lm, "RWA_Preview") ~= nil then return true end
  if find_layer_only(lm, "RWA_FrontPreview") ~= nil then return true end
  if find_layer_only(lm, "RWA_Assembly_IDs") ~= nil then return true end
  if find_layer_only(lm, "RWA_Slats_S01") ~= nil then return true end
  if find_layer_only(lm, "RWA_Backer_S01") ~= nil then return true end
  if find_layer_only(lm, "RWA_Rails_S01") ~= nil then return true end
  return false
end

local function show_layers_required_message(dialog, for_what)
  local body = "Wall art layers must be generated first"
  if for_what ~= nil and tostring(for_what) ~= "" then
    body = body .. " before " .. tostring(for_what)
  end
  body = body .. " for the current Pro session."
  DisplayMessageBox(body)
end

local function select_existing_depth_map_file(existing_path)
  local file_dialog = FileDialog()
  local seed_path = normalize_selected_path(existing_path or '')
  local filter = 'Depth Maps (*.csv;*.pgm)|*.csv;*.pgm|CSV Files (*.csv)|*.csv|PGM Files (*.pgm)|*.pgm|All Files (*.*)|*.*||'
  if trim(seed_path) ~= '' then
    local initial_dir = string.match(seed_path, '^(.*)[\\/][^\\/]*$')
    if trim(initial_dir) ~= '' then file_dialog.InitialDirectory = initial_dir end
  elseif trim(g_script_path or '') ~= '' then
    file_dialog.InitialDirectory = g_script_path
    seed_path = join_dir_file(g_script_path, '*.csv')
  else
    seed_path = '*.csv'
  end
  if not file_dialog:FileOpen('', seed_path, filter) then
    return ''
  end
  return normalize_selected_path(file_dialog.PathName)
end

function OnLuaButton_ChooseDepthMap(dialog)
  local ok, err = pcall(function()
    local existing_path = normalize_selected_path(dialog:GetTextField("DepthMapPath"))
    local path = select_existing_depth_map_file(existing_path)
    path = normalize_selected_path(path)
    if trim(path) == "" then return end
    g_options.depth_map_path = path
    g_options.mode = "Depth Map"
    g_generated_this_session = false
    dialog:UpdateTextField("DepthMapPath", g_options.depth_map_path)
    dialog:UpdateDropDownListValue("Mode", g_options.mode)
    refresh_hint(dialog)
  end)
  if not ok then
    DisplayMessageBox("Depth map selection error: " .. tostring(err))
  end
  return true
end

function OnLuaSelector_BuiltinPreset(dialog)
  local success, err = pcall(function() pull_options_from_dialog(dialog) apply_preset(dialog:GetDropDownListValue("BuiltinPreset")) push_options_to_dialog(dialog) end)
  if not success then DisplayMessageBox("Preset selection error:\n" .. tostring(err)) end
  return true
end
function OnLuaButton_GiftMe(dialog)
  local html = build_gift_html()
  local out_path = join_dir_file(g_script_path, 'RWA_Gift_Me.html')
  if not write_text_file(out_path, html) then
    DisplayMessageBox("Could not write the Gift Me page:\n" .. tostring(out_path) .. "\n\nOpen this link manually:\n" .. tostring(STRIPE_GIFT_URL))
    return true
  end
  local opened = open_in_browser(out_path)
  if opened == nil or opened == 0 or opened == true then
    return true
  end
  DisplayMessageBox("Could not open the Gift Me page automatically.\n\nOpen this file manually:\n" .. tostring(out_path) .. "\n\nor open this link manually:\n" .. tostring(STRIPE_GIFT_URL))
  return true
end

function OnLuaButton_Open3DPreview(dialog)
  if not ensure_supported_job(g_job) then clear_preview_busy(dialog) return true end
  if not g_generated_this_session then clear_preview_busy(dialog) show_layers_required_message(dialog, "opening the 3D preview") return true end
  local success, err = pcall(function() pull_options_from_dialog(dialog) end)
  if not success then clear_preview_busy(dialog) DisplayMessageBox("Dialog read error:\n" .. tostring(err)) return true end
  local ok, msg = validate_options(g_job)
  if not ok then clear_preview_busy(dialog) DisplayMessageBox(msg) return true end
  local data = nil
  success, err = pcall(function() data = build_preview_export_data() end)
  if not success then clear_preview_busy(dialog) DisplayMessageBox("3D preview export error:\n" .. tostring(err)) return true end
  local html = build_threejs_preview_html(data)
  local out_path = join_dir_file(g_script_path, 'RWA_3D_Preview_' .. tostring(os.time()) .. '.html')
  if not write_text_file(out_path, html) then
    clear_preview_busy(dialog)
    DisplayMessageBox("Could not write the 3D preview HTML file:\n" .. tostring(out_path))
    return true
  end
  clear_preview_busy(dialog)
  local opened = open_in_browser(out_path)
  if opened == nil or opened == 0 or opened == true then
    return true
  else
    DisplayMessageBox("3D preview exported, but the browser did not open automatically.\n\nOpen this file manually:\n" .. tostring(out_path) .. "\n\nNote: this preview uses Three.js from a CDN, so internet access is needed the first time it loads.")
  end
  return true
end

function OnLuaButton_GenerateGeometry(dialog)
  if not ensure_supported_job(g_job) then return true end
  local success, err = pcall(function() pull_options_from_dialog(dialog) end)
  if not success then DisplayMessageBox("Dialog read error:\n" .. tostring(err)) return true end
  local ok, msg = validate_options(g_job)
  if not ok then DisplayMessageBox(msg) return true end
  local effective_sheet_margin = safe_max(g_options.sheet_margin, min_clamp_margin(g_job))
  local usable_y = g_job.Height - (effective_sheet_margin * 2.0)
  if g_options.create_slat_layout and g_options.panel_height > usable_y then
    DisplayMessageBox("Warning: slat length exceeds the usable Y dimension of the material.\n\nUsable Y: " .. string.format("%.3f", usable_y) .. "\nSlat length: " .. string.format("%.3f", g_options.panel_height) .. "\n\nIncrease the material height or reduce the panel height before generating cut geometry.")
    return true
  end
  local result = nil
  success, err = pcall(function() result = generate_geometry(g_job) end)
  if not success then DisplayMessageBox("Generation error:\n" .. tostring(err)) return true end
  g_generated_this_session = true
  local msg_out = "Production geometry generated.\nObjects added: " .. tostring(result.object_count) .. "\nOutput: " .. tostring(result.route_text)
  msg_out = msg_out .. "\nPreview ribs: " .. tostring(result.preview_rib_count)
  msg_out = msg_out .. "\nCut slats: " .. tostring(result.slat_part_count)
  if g_options.number_slats then msg_out = msg_out .. "\nSlat ID strokes: " .. tostring(result.slat_id_count) end
  if g_options.number_preview then msg_out = msg_out .. "\nPreview ID strokes: " .. tostring(result.preview_id_count) end
  if g_options.create_backer then msg_out = msg_out .. "\nBacker parts: " .. tostring(result.backer_part_count) end
  if g_options.create_guide_rails then msg_out = msg_out .. "\nRail parts: " .. tostring(result.rail_part_count) end
  if g_options.create_guide_rails then msg_out = msg_out .. "\nRail X marks: " .. tostring(result.rail_mark_count) end
  msg_out = msg_out .. "\nSheet layers used: " .. tostring(result.sheet_count)
  if g_options.mode == "Depth Map" then msg_out = msg_out .. "\nSource: " .. tostring(result.source_text) end
  if result.omitted_parts > 0 then msg_out = msg_out .. "\nOmitted parts: " .. tostring(result.omitted_parts) end
  if result.preview_overlay then msg_out = msg_out .. "\nPreview overlay used: yes" end
  DisplayMessageBox(msg_out)
  return true
end


local TOOLPATH_DIALOG_HTML = [[
<!DOCTYPE html>
<html><head><meta charset="utf-8" />
<title>Generate Toolpaths</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; font-size: 13px; margin: 12px; background: #f4f6f8; color: #1f2933; }
.card { background: #fff; border: 1px solid #d8dde6; border-radius: 10px; padding: 14px 16px; box-shadow: 0 1px 1px rgba(0,0,0,0.03); margin-bottom: 12px; }
h1 { margin: 0 0 8px 0; font-size: 22px; color: #17395f; }
h3 { margin: 0 0 10px 0; font-size: 15px; color: #24476e; border-bottom: 1px solid #e5ebf1; padding-bottom: 6px; }
.grid2 { display:grid; grid-template-columns: 1fr 1fr; gap: 8px 12px; }
label { display:block; font-weight:600; margin-bottom:4px; color:#2d3748; }
input[type="text"], select { width:100%; box-sizing:border-box; padding:6px 7px; border:1px solid #b9c3cf; border-radius:5px; background:#fff; }
.checks { display:grid; gap: 6px; margin-top: 8px; }
body.rwa-busy, body.rwa-busy * { cursor: wait !important; }
#rwaTpBusyOverlay { display:none; position:fixed; inset:0; background:rgba(244,246,248,0.72); z-index:9999; align-items:center; justify-content:center; }
#rwaTpBusyOverlay.show { display:flex; }
.rwaTpBusyCard { background:#ffffff; border:1px solid #d8dde6; border-radius:12px; padding:18px 22px; min-width:280px; box-shadow:0 6px 24px rgba(0,0,0,0.12); text-align:center; }
.rwaTpSpinner { width:28px; height:28px; margin:0 auto 12px auto; border-radius:50%; border:3px solid #c7d5e6; border-top-color:#2c5d95; animation:rwaTpSpin 0.85s linear infinite; }
.rwaTpBusyText { font-weight:700; color:#24476e; }
.rwaTpBusySub { margin-top:6px; font-size:12px; color:#667; }
@keyframes rwaTpSpin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }
</style></head><body>
<div class="card">
  <h1>Generate Toolpaths</h1>
  <div>Create exactly one profile toolpath per detected RWA_ cut layer.</div>
</div>
<div class="card">
  <h3>Profile Toolpath Session</h3>
  <div class="grid2">
    <div><label>Toolpath Name Prefix</label><input id="TpNamePrefix" name="TpNamePrefix" type="text"></div>
    <div><label>Machine Side</label><select id="TpMachineSide" name="TpMachineSide"></select></div>
    <div><label>Start Depth</label><input id="TpStartDepth" name="TpStartDepth" type="text"></div>
    <div><label>Cut Depth</label><input id="TpCutDepth" name="TpCutDepth" type="text"></div>
    <div><label>Tool Diameter</label><input id="TpToolDiameter" name="TpToolDiameter" type="text"></div>
    <div><label>Allowance</label><input id="TpAllowance" name="TpAllowance" type="text"></div>
    <div><label>Ramp Distance</label><input id="TpRampDistance" name="TpRampDistance" type="text"></div>
    <div><label>Tab Length</label><input id="TpTabLength" name="TpTabLength" type="text"></div>
    <div><label>Tab Thickness</label><input id="TpTabThickness" name="TpTabThickness" type="text"></div>
    <div><label>Tabs Per Closed Vector</label><input id="TpTabCount" name="TpTabCount" type="text"></div>
    <div></div>
  </div>
  <div class="checks">
    <label><input id="TpUseTabs" name="TpUseTabs" type="checkbox"> Add tabs / bridges to slat profile toolpaths</label>
    <label><input id="TpUseRamp" name="TpUseRamp" type="checkbox"> Use ramp plunge</label>
    <label><input id="TpIncludeBacker" name="TpIncludeBacker" type="checkbox"> Include backer layers when present</label>
    <label><input id="TpIncludeRails" name="TpIncludeRails" type="checkbox"> Include rail layers when present</label>
  </div>
  <div style="margin-top:12px; display:flex; justify-content:center;">
    <button class="LuaButton" id="CreateToolpaths" name="CreateToolpaths" type="button" style="min-width:220px; padding:9px 14px;">Create Toolpaths</button>
  </div>
</div>
</body></html>
]]

find_layer_only = function(layer_manager, name)
  local ok, res
  if layer_manager == nil then return nil end
  if layer_manager.FindLayerWithName ~= nil then
    ok, res = pcall(function() return layer_manager:FindLayerWithName(name) end)
    if ok and res ~= nil then return res end
  end
  return nil
end

local function layer_has_closed_vectors(layer)
  if layer == nil then return false end
  local pos = layer:GetHeadPosition()
  while pos ~= nil do
    local object
    object, pos = layer:GetNext(pos)
    if object ~= nil then
      local contour = object:GetContour()
      if contour ~= nil and (not contour.IsOpen) then
        return true
      end
    end
  end
  return false
end

local function SelectVectorsOnLayer(layer, selection, select_closed, select_open, select_groups)
  local objects_selected = false
  local warning_displayed = false
  if layer == nil or selection == nil then return false end
  local pos = layer:GetHeadPosition()
  while pos ~= nil do
    local object
    object, pos = layer:GetNext(pos)
    local contour = object:GetContour()
    if contour == nil then
      if (object.ClassName == "vcCadObjectGroup") and select_groups then
        selection:Add(object, true, true)
        objects_selected = true
      else
        if not warning_displayed then
          local message = "Object(s) without contour information found on layer - ignoring"
          if not select_groups then
            message = message .. "\r\n\r\nIf layer contains grouped vectors these must be ungrouped for this script"
          end
          DisplayMessageBox(message)
          warning_displayed = true
        end
      end
    else
      if contour.IsOpen and select_open then
        selection:Add(object, true, true)
        objects_selected = true
      elseif (not contour.IsOpen) and select_closed then
        selection:Add(object, true, true)
        objects_selected = true
      end
    end
  end
  if objects_selected then
    selection:GroupSelectionFinished()
  end
  return objects_selected
end

local function build_profile_tool(job, cut_depth, requested_tool_dia)
  local tool = Tool("RWA Profile End Mill", Tool.END_MILL)
  local in_mm = job ~= nil and job.InMM or false
  local default_tool_dia = in_mm and 6.0 or 0.25
  local tool_dia = tonumber(requested_tool_dia) or default_tool_dia
  if tool_dia <= 0.0 then tool_dia = default_tool_dia end
  local stepdown = math.min(tool_dia, in_mm and 3.0 or 0.25)
  if cut_depth ~= nil and cut_depth > 0.0 then
    stepdown = math.min(stepdown, cut_depth)
  end
  tool.InMM = in_mm
  tool.ToolDia = tool_dia
  tool.Stepdown = stepdown
  tool.Stepover = tool_dia * 0.25
  pcall(function() tool.RateUnits = in_mm and Tool.MM_MIN or Tool.INCHES_MIN end)
  pcall(function() tool.Rate_Units = in_mm and Tool.MM_MIN or Tool.INCHES_MIN end)
  pcall(function() tool.FeedRate = in_mm and 1800 or 75 end)
  pcall(function() tool.Feed_Rate = in_mm and 1800 or 75 end)
  pcall(function() tool.PlungeRate = in_mm and 600 or 20 end)
  pcall(function() tool.Plunge_Rate = in_mm and 600 or 20 end)
  pcall(function() tool.SpindleSpeed = 18000 end)
  pcall(function() tool.Spindle_Speed = 18000 end)
  pcall(function() tool.ToolNumber = 1 end)
  pcall(function() tool.Tool_Number = 1 end)
  pcall(function() tool.VBitAngle = 90.0 end)
  pcall(function() tool.VBit_Angle = 90.0 end)
  pcall(function() tool.ClearStepover = tool_dia * 0.5 end)
  pcall(function() tool.Clear_Stepover = tool_dia * 0.5 end)
  return tool
end

local function build_profile_side_value(side_name)
  if side_name == "Inside" then return ProfileParameterData.PROFILE_INSIDE end
  if side_name == "On" then return ProfileParameterData.PROFILE_ON end
  return ProfileParameterData.PROFILE_OUTSIDE
end

local function build_toolpath_position_data(job)
  local mtl_block = MaterialBlock()
  local mtl_box = mtl_block.MaterialBox
  local mtl_box_blc = mtl_box.BLC
  local pos_data = ToolpathPosData()
  pos_data:SetHomePosition(mtl_box_blc.x, mtl_box_blc.y, mtl_box.TRC.z + (mtl_block.Thickness * 0.2))
  pos_data.SafeZGap = math.max(mtl_block.Thickness * 0.1, (job ~= nil and job.InMM) and 3.0 or 0.125)
  return pos_data
end

local function get_tab_count(dlg)
  local raw = tonumber(dlg:GetTextField("TpTabCount")) or 4
  local count = math.floor(raw + 0.5)
  if count < 1 then count = 1 end
  if count > 12 then count = 12 end
  return count
end

local function get_bbox_tab_points(box2d, count)
  local pts = {}
  if box2d == nil or count <= 0 then return pts end
  local min_x = box2d.BLC.x
  local min_y = box2d.BLC.y
  local max_x = box2d.TRC.x
  local max_y = box2d.TRC.y
  local cx = (min_x + max_x) * 0.5
  local cy = (min_y + max_y) * 0.5
  local rx = math.max((max_x - min_x) * 0.5, 0.001)
  local ry = math.max((max_y - min_y) * 0.5, 0.001)
  local i
  for i = 1, count do
    local angle = ((i - 1) / count) * (math.pi * 2.0)
    pts[#pts + 1] = Point2D(cx + (rx * math.cos(angle)), cy + (ry * math.sin(angle)))
  end
  return pts
end

local function add_tabs_to_selected_vectors(selection, dlg)
  if selection == nil or selection.IsEmpty or not dlg:GetCheckBox("TpUseTabs") then
    return 0
  end
  local tabs_added = 0
  local tab_count = get_tab_count(dlg)
  local pos = selection:GetHeadPosition()
  while pos ~= nil do
    local obj
    obj, pos = selection:GetNext(pos)
    if obj ~= nil and obj.GetContour ~= nil then
      local contour = obj:GetContour()
      if contour ~= nil and not contour.IsOpen and obj.InsertToolpathTabAtPoint ~= nil then
        local pts = get_bbox_tab_points(contour.BoundingBox2D, tab_count)
        local i
        for i = 1, #pts do
          local ok = pcall(function() obj:InsertToolpathTabAtPoint(pts[i]) end)
          if ok then tabs_added = tabs_added + 1 end
        end
      end
    end
  end
  return tabs_added
end

local function create_profile_toolpath_from_selection(job, name, dlg)
  local tool = build_profile_tool(job, dlg:GetDoubleField("TpCutDepth"), dlg:GetDoubleField("TpToolDiameter"))
  local profile_data = ProfileParameterData()
  profile_data.StartDepth = dlg:GetDoubleField("TpStartDepth")
  profile_data.CutDepth = dlg:GetDoubleField("TpCutDepth")
  profile_data.CutDirection = ProfileParameterData.CLIMB_DIRECTION
  profile_data.ProfileSide = build_profile_side_value(dlg:GetDropDownListValue("TpMachineSide"))
  profile_data.Allowance = dlg:GetDoubleField("TpAllowance")
  profile_data.KeepStartPoints = false
  profile_data.CreateSquareCorners = false
  profile_data.CornerSharpen = false
  profile_data.UseTabs = dlg:GetCheckBox("TpUseTabs")
  profile_data.TabLength = dlg:GetDoubleField("TpTabLength")
  profile_data.TabThickness = dlg:GetDoubleField("TpTabThickness")
  profile_data.Use3dTabs = true
  profile_data.ProjectToolpath = false

  local ramping_data = RampingData()
  ramping_data.DoRamping = dlg:GetCheckBox("TpUseRamp")
  ramping_data.RampType = RampingData.RAMP_ZIG_ZAG
  ramping_data.RampConstraint = RampingData.CONSTRAIN_DISTANCE
  ramping_data.RampDistance = dlg:GetDoubleField("TpRampDistance")
  ramping_data.RampAngle = 25.0
  ramping_data.RampMaxAngleDist = dlg:GetDoubleField("TpRampDistance")
  ramping_data.RampOnLeadIn = false

  local lead_in_out_data = LeadInOutData()
  lead_in_out_data.DoLeadIn = false
  lead_in_out_data.DoLeadOut = false
  lead_in_out_data.LeadType = LeadInOutData.CIRCULAR_LEAD

  if dlg:GetCheckBox("TpUseTabs") then
    add_tabs_to_selected_vectors(job.Selection, dlg)
  end

  local geometry_selector = GeometrySelector()
  local toolpath_manager = ToolpathManager()
  local toolpath_id = toolpath_manager:CreateProfilingToolpath(name, tool, profile_data, ramping_data, lead_in_out_data, build_toolpath_position_data(job), geometry_selector, true, true)
  if toolpath_id == nil then
    return false, "Error creating toolpath \"" .. tostring(name) .. "\"."
  end
  return true, toolpath_id
end

local discover_sheet_layers

local function collect_target_toolpath_layers(job, dlg)
  local layers = {}
  local seen = {}
  local function append(list)
    local i, name
    for i = 1, #list do
      name = list[i]
      if name ~= nil and not seen[name] then
        seen[name] = true
        layers[#layers + 1] = name
      end
    end
  end
  append(discover_sheet_layers(job, "RWA_Slats"))
  if dlg:GetCheckBox("TpIncludeBacker") then append(discover_sheet_layers(job, "RWA_Backer")) end
  if dlg:GetCheckBox("TpIncludeRails") then append(discover_sheet_layers(job, "RWA_Rails")) end
  table.sort(layers)
  return layers
end

discover_sheet_layers = function(job, prefix)
  local found = {}
  local indexed = {}
  local idx
  if job == nil or (not job.Exists) or job.LayerManager == nil then return found end
  for idx = 1, 99 do
    local name = prefix .. string.format("_S%02d", idx)
    local layer = find_layer_only(job.LayerManager, name)
    if layer ~= nil and layer_has_closed_vectors(layer) then
      indexed[#indexed + 1] = { idx = idx, name = name }
    end
  end
  table.sort(indexed, function(a, b) return a.idx < b.idx end)
  for idx = 1, #indexed do
    found[#found + 1] = indexed[idx].name
  end
  return found
end

local function join_lines(lines)
  return table.concat(lines, "\n")
end

local function build_toolpath_session_lines(job, dlg, created_names, skipped_lines)
  local target_layers = collect_target_toolpath_layers(job, dlg)
  local target_lines = {}
  local i
  table.insert(target_lines, "Pro toolpaths created.")
  table.insert(target_lines, "")
  table.insert(target_lines, "Name prefix: " .. tostring(dlg:GetTextField("TpNamePrefix")))
  table.insert(target_lines, "Machine side: " .. tostring(dlg:GetDropDownListValue("TpMachineSide")))
  table.insert(target_lines, string.format("Start depth: %.4f", dlg:GetDoubleField("TpStartDepth")))
  table.insert(target_lines, string.format("Cut depth: %.4f", dlg:GetDoubleField("TpCutDepth")))
  table.insert(target_lines, string.format("Tool diameter: %.4f", dlg:GetDoubleField("TpToolDiameter")))
  table.insert(target_lines, string.format("Allowance: %.4f", dlg:GetDoubleField("TpAllowance")))
  table.insert(target_lines, string.format("Ramp distance: %.4f", dlg:GetDoubleField("TpRampDistance")))
  table.insert(target_lines, "Use tabs: " .. tostring(dlg:GetCheckBox("TpUseTabs")))
  if dlg:GetCheckBox("TpUseTabs") then
    table.insert(target_lines, "Tabs per closed vector: " .. tostring(get_tab_count(dlg)))
  end
  table.insert(target_lines, "Use ramp: " .. tostring(dlg:GetCheckBox("TpUseRamp")))
  table.insert(target_lines, "Toolpath creation mode: one toolpath per detected RWA_ layer")
  table.insert(target_lines, "")
  table.insert(target_lines, "Target layers detected: " .. tostring(#target_layers))
  if #target_layers > 0 then
    local preview_count = math.min(#target_layers, 10)
    for i = 1, preview_count do table.insert(target_lines, "  " .. tostring(target_layers[i])) end
    if #target_layers > preview_count then
      table.insert(target_lines, "  ... and " .. tostring(#target_layers - preview_count) .. " more layer(s)")
    end
  end
  table.insert(target_lines, "")
  table.insert(target_lines, "Toolpaths created: " .. tostring(#created_names))
  if #created_names > 0 then
    local preview_count = math.min(#created_names, 12)
    for i = 1, preview_count do table.insert(target_lines, "  " .. tostring(created_names[i])) end
    if #created_names > preview_count then
      table.insert(target_lines, "  ... and " .. tostring(#created_names - preview_count) .. " more toolpath(s)")
    end
  end
  if skipped_lines ~= nil and #skipped_lines > 0 then
    table.insert(target_lines, "")
    table.insert(target_lines, "Skipped:")
    for i = 1, #skipped_lines do table.insert(target_lines, "  " .. tostring(skipped_lines[i])) end
  end
  return target_lines
end

local function run_toolpath_session(job, dlg)
  if g_toolpath_session_running then
    return false
  end
  g_toolpath_session_running = true
  g_toolpath_dialog_ran = true
  local selection = job.Selection
  local prefix = trim(dlg:GetTextField("TpNamePrefix"))
  local target_layers = collect_target_toolpath_layers(job, dlg)
  local created_names = {}
  local skipped_lines = {}
  local i
  if prefix == "" then prefix = "RWAG_" end
  if #target_layers == 0 then
    g_toolpath_session_running = false
    DisplayMessageBox("No generated slat, backer, or rail layers were found. Generate geometry first, then run Create Toolpaths.")
    return false
  end
  selection:Clear()
  for i = 1, #target_layers do
    local layer_name = target_layers[i]
    local layer = find_layer_only(job.LayerManager, layer_name)
    if layer ~= nil then
      selection:Clear()
      if SelectVectorsOnLayer(layer, selection, true, false, true) and not selection.IsEmpty then
        local toolpath_name = prefix .. layer_name:gsub("^RWA_", "")
        local ok, result = create_profile_toolpath_from_selection(job, toolpath_name, dlg)
        if ok then
          created_names[#created_names + 1] = toolpath_name
        else
          skipped_lines[#skipped_lines + 1] = tostring(result)
        end
      else
        skipped_lines[#skipped_lines + 1] = "No closed vectors found on layer \"" .. tostring(layer_name) .. "\"."
      end
    else
      skipped_lines[#skipped_lines + 1] = "Layer not found: \"" .. tostring(layer_name) .. "\"."
    end
  end
  selection:Clear()
  g_toolpath_session_running = false
  if #created_names == 0 then
    local lines = {"No toolpaths were created."}
    if #skipped_lines > 0 then
      lines[#lines + 1] = ""
      lines[#lines + 1] = "Details:"
      for i = 1, #skipped_lines do lines[#lines + 1] = tostring(skipped_lines[i]) end
    end
    DisplayMessageBox(join_lines(lines))
    return false
  end
  DisplayMessageBox(join_lines(build_toolpath_session_lines(job, dlg, created_names, skipped_lines)))
  pcall(function() dlg:EndDialog(true) end)
  return true
end

local function show_toolpath_dialog(job)
  local dlg = HTML_Dialog(true, TOOLPATH_DIALOG_HTML, 760, 620, "Generate Toolpaths")

  g_toolpath_dialog_ran = false
  dlg:AddTextField("TpNamePrefix", "RWAG_")
  dlg:AddDropDownList("TpMachineSide", "Outside")
  dlg:AddDropDownListValue("TpMachineSide", "Outside")
  dlg:AddDropDownListValue("TpMachineSide", "On")
  dlg:AddDropDownListValue("TpMachineSide", "Inside")
  dlg:AddDoubleField("TpStartDepth", 0.0)
  dlg:AddDoubleField("TpCutDepth", from_inch(job, 0.80))
  dlg:AddDoubleField("TpToolDiameter", from_inch(job, 0.25))
  dlg:AddDoubleField("TpAllowance", 0.0)
  dlg:AddDoubleField("TpRampDistance", from_inch(job, 0.25))
  dlg:AddDoubleField("TpTabLength", from_inch(job, 0.5))
  dlg:AddDoubleField("TpTabThickness", from_inch(job, 0.5))
  dlg:AddTextField("TpTabCount", "4")
  dlg:AddCheckBox("TpUseTabs", true)
  dlg:AddCheckBox("TpUseRamp", true)
  dlg:AddCheckBox("TpIncludeBacker", false)
  dlg:AddCheckBox("TpIncludeRails", false)

  dlg:ShowDialog()
end

function OnLuaButton_CreateToolpaths(dialog)
  if g_job == nil or not g_job.Exists then
    DisplayMessageBox("Open or create a job first.")
    return true
  end
  local ok, err = pcall(function() run_toolpath_session(g_job, dialog) end)
  g_toolpath_session_running = false
  if not ok then
    DisplayMessageBox("Toolpath creation error:\n" .. tostring(err))
  end
  return true
end

function OnLuaButton_GenerateToolpaths(dialog)
  if not ensure_supported_job(g_job) then
    clear_preview_busy(dialog)
    return true
  end
  if not g_generated_this_session then
    clear_preview_busy(dialog)
    show_layers_required_message(dialog, "generating toolpaths")
    return true
  end
  clear_preview_busy(dialog)
  show_toolpath_dialog(g_job)
  return true
end

function main(script_path)
  local dialog
  g_script_path = normalize_dir_path(script_path or "")
  g_generated_this_session = false
  g_job = VectricJob()
  if g_job ~= nil and g_job.Exists then g_generated_this_session = has_generated_wall_art_layers(g_job) end
  if not ensure_supported_job(g_job) then
    return false
  end
  reset_unit_state(g_job)
  dialog = HTML_Dialog(true, DIALOG_HTML, 980, 820, GADGET_NAME .. " " .. GADGET_VERSION)
  bind_dialog_fields(dialog)
  refresh_hint(dialog)
  pcall(function() dialog:UpdateTextField("WarnSignal", "0") end)
  dialog:ShowDialog()
  return true
end
