$out_dir = "build"; 
$pdf_mode = 4; # LuaLaTeX 
@default_files = ("notulen_bestuursvergaderingen.tex");

# Linux/MacOS
# $success_cmd="open %D";

# Windows
$success_cmd="start %D";
