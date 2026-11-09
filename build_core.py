import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def add_header_footer(doc):
    for s in doc.sections:
        s.top_margin = Inches(0.8)
        s.bottom_margin = Inches(0.8)
        s.left_margin = Inches(0.8)
        s.right_margin = Inches(0.8)
        
        # Header
        header = s.header
        hp = header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun = hp.add_run("KharchaBook — MAD Lab Project (BS-IT 6A) | Assignment 2: UI Submission")
        hrun.font.name = "Segoe UI"
        hrun.font.size = Pt(8.5)
        hrun.font.color.rgb = RGBColor(148, 163, 184)
        
        # Footer
        footer = s.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        frun = fp.add_run("Bahria University Islamabad — Department of Computer Science • Zain Kashif & Huraira Minhas")
        frun.font.name = "Segoe UI"
        frun.font.size = Pt(8.5)
        frun.font.color.rgb = RGBColor(148, 163, 184)

def add_styled_heading(doc, text, level):
    p = doc.add_paragraph()
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.bold = True
    run.font.name = "Segoe UI"
    
    if level == 1:
        p.paragraph_format.space_before = Pt(20)
        p.paragraph_format.space_after = Pt(8)
        run.font.size = Pt(15)
        run.font.color.rgb = RGBColor(15, 23, 42) # Slate 900
        pBdr = parse_xml(f'<w:pBdr {nsdecls("w")}><w:bottom w:val="single" w:sz="12" w:space="4" w:color="2563EB"/></w:pBdr>')
        p._p.get_or_add_pPr().append(pBdr)
    elif level == 2:
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(4)
        run.font.size = Pt(12)
        run.font.color.rgb = RGBColor(30, 41, 59) # Slate 800
    elif level == 3:
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(2)
        run.font.size = Pt(10.5)
        run.font.color.rgb = RGBColor(71, 85, 105) # Slate 600
    return p

def add_p(doc, text="", bold_prefix="", space_after=5):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.bold = True
        r_pre.font.name = "Segoe UI"
        r_pre.font.size = Pt(9.5)
        r_pre.font.color.rgb = RGBColor(15, 23, 42)
    if text:
        r_text = p.add_run(text)
        r_text.font.name = "Segoe UI"
        r_text.font.size = Pt(9.5)
        r_text.font.color.rgb = RGBColor(51, 65, 85)
    return p

def add_bullet(doc, bold_title, text):
    p = doc.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.line_spacing = 1.15
    r_title = p.add_run(bold_title)
    r_title.bold = True
    r_title.font.name = "Segoe UI"
    r_title.font.size = Pt(9.5)
    r_title.font.color.rgb = RGBColor(30, 41, 59)
    
    r_text = p.add_run(text)
    r_text.font.name = "Segoe UI"
    r_text.font.size = Pt(9.5)
    r_text.font.color.rgb = RGBColor(71, 85, 105)
    return p

def add_screenshot_section(doc, img_path, caption, screen_title, description, width_inches=2.75):
    table = doc.add_table(rows=1, cols=2)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    table.columns[0].width = Inches(3.05)
    table.columns[1].width = Inches(3.85)
    
    # Left: Image
    cell_img = table.cell(0, 0)
    set_cell_background(cell_img, "F8FAFC")
    set_cell_margins(cell_img, top=100, bottom=100, left=100, right=100)
    p_img = cell_img.paragraphs[0]
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_after = Pt(4)
    
    if os.path.exists(img_path):
        p_img.add_run().add_picture(img_path, width=Inches(width_inches))
    else:
        p_img.add_run(f"[Screenshot Missing: {img_path}]")
        
    p_cap = cell_img.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_after = Pt(2)
    r_cap = p_cap.add_run(caption)
    r_cap.italic = True
    r_cap.font.name = "Segoe UI"
    r_cap.font.size = Pt(8.0)
    r_cap.font.color.rgb = RGBColor(100, 116, 139)
    
    # Right: Description
    cell_desc = table.cell(0, 1)
    set_cell_background(cell_desc, "FFFFFF")
    set_cell_margins(cell_desc, top=100, bottom=100, left=120, right=100)
    
    p_title = cell_desc.paragraphs[0]
    p_title.paragraph_format.space_after = Pt(6)
    r_title = p_title.add_run(screen_title)
    r_title.bold = True
    r_title.font.name = "Segoe UI"
    r_title.font.size = Pt(11)
    r_title.font.color.rgb = RGBColor(15, 23, 42)
    
    for paragraph in description.split("\n\n"):
        if paragraph.strip():
            p = cell_desc.add_paragraph()
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.line_spacing = 1.15
            run = p.add_run(paragraph.strip())
            run.font.name = "Segoe UI"
            run.font.size = Pt(9.0)
            run.font.color.rgb = RGBColor(51, 65, 85)
            
    doc.add_paragraph().paragraph_format.space_after = Pt(8)

def add_code_block(doc, title, code_text):
    if title:
        tp = doc.add_paragraph()
        tp.paragraph_format.space_before = Pt(8)
        tp.paragraph_format.space_after = Pt(2)
        tr = tp.add_run(f"Listing: {title}")
        tr.bold = True
        tr.font.name = "Segoe UI"
        tr.font.size = Pt(9.0)
        tr.font.color.rgb = RGBColor(30, 58, 138)
        
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    table.columns[0].width = Inches(6.9)
    
    cell = table.cell(0, 0)
    set_cell_background(cell, "F8FAFC")
    set_cell_margins(cell, top=100, bottom=100, left=140, right=140)
    
    tcPr = cell._tc.get_or_add_tcPr()
    tcBorders = parse_xml(f'<w:tcBorders {nsdecls("w")}><w:top w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/><w:left w:val="single" w:sz="16" w:space="0" w:color="2563EB"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/><w:right w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/></w:tcBorders>')
    tcPr.append(tcBorders)
    
    cp = cell.paragraphs[0]
    cp.paragraph_format.space_before = Pt(0)
    cp.paragraph_format.space_after = Pt(0)
    cp.paragraph_format.line_spacing = 1.05
    crun = cp.add_run(code_text.strip())
    crun.font.name = "Consolas"
    crun.font.size = Pt(7.5)
    crun.font.color.rgb = RGBColor(15, 23, 42)
    
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

print("Builder core ready.")
