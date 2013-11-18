import argparse
import os
import textile
import re

#Ugly hack to force the replacement of the whole middle section in RAW_HTML mode
#Instead of just the #TEX2HTML_BODY section (index.html uses this)
raw_mode_replace="""      <section class="justified centered">
        <center>
        <h1>#TEX2HTML_PAGETITLE</h1>
        </center>
          #TEX2HTML_BODY
      </section>"""

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def links(fulldata):
    """Build the list of links based on all the pages found and put them in increasing order"""
    links_txt = ''
    for entry in fulldata:
        #Only files with the LINK_TITLE option will appear as links in the sidebar
        if 'LINK_TITLE' in entry['options']:
            links_txt += '<li><a href="%s">%s</a></li>\n' % (entry['htmlfile'], entry['options']['LINK_TITLE'])
    return links_txt

def format_pre(text):
    pre_end=0
    while True:
        #Sliding window through the file, fixes formatting errors within <pre> tags
        current_index = pre_end
        pre_start = text[pre_end:].find('<pre>')
        pre_end = text[pre_end:].find('</pre>') + len('</pre>')
        if pre_start == -1 or pre_end == -1:
            return text
        format_pre_rules = {'<br />':'\n', '\t<p>':'', '</p>':''}
        def fn(match):
            return format_pre_rules[match.group()]
        newtext = re.sub('|'.join(re.escape(k) for k in format_pre_rules), fn, text[current_index+pre_start:current_index+pre_end])
        text = text[:current_index+pre_start] + newtext + text[current_index+pre_end:]
        pre_end = current_index + pre_start + len(newtext)

def postprocessing(text):
    text = format_pre(text)
    return text

def generate(template, sourcedir, outdir):
    textile_files = [ f for f in os.listdir(sourcedir) if os.path.isfile(os.path.join(sourcedir,f)) and f.endswith('.textile')]
    page_template = open(template, 'r').read()
    fulldata = []
    for textile_file in textile_files:
        contents = open(os.path.join(sourcedir,textile_file), 'r').read()
        contents_parts = contents.split('===//===//===')
        options_raw = contents_parts[0].split('\n')
        options_dict = {}
        for option in options_raw:
            if '=' in option:
                parts = option.split('=')
                options_dict[parts[0]] = parts[1]
        fulldata_entry = {}
        fulldata_entry['options'] = options_dict
        fulldata_entry['textilefile'] = textile_file

        if 'MODE' in options_dict and options_dict['MODE'] == 'RAW_HTML':
            fulldata_entry['htmlcontent'] = contents_parts[1]
        else:
            fulldata_entry['htmlcontent'] = postprocessing(textile.textile(contents_parts[1]))
        order_txt = textile_file.split('-')[0]
        if is_number(order_txt):
            fulldata_entry['order'] = int(order_txt)
            order_len = len(order_txt)+1
        else:
            order_txt = ''
            order_len = 0
            fulldata_entry['order'] = -1
        fulldata_entry['htmlfile'] = os.path.join(outdir,textile_file[order_len:-8]+'.html')
        fulldata.append(fulldata_entry)
    
    fulldata = sorted(fulldata, key=lambda k: k['order']) 
    links_txt = links(fulldata)
    
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    
    for entry in fulldata:
        htmlfile = open(entry['htmlfile'], 'w')
        htmlcontents = page_template
        if 'MODE' in entry['options'] and entry['options']['MODE'] == 'RAW_HTML':
            htmlcontents = htmlcontents.replace(raw_mode_replace, entry['htmlcontent'])
        else:
            htmlcontents = htmlcontents.replace('#TEX2HTML_PAGETITLE', entry['options']['PAGE_TITLE'])
            htmlcontents = htmlcontents.replace('#TEX2HTML_BODY', entry['htmlcontent'])
        htmlcontents = htmlcontents.replace('#TEX2HTML_LINKS', links_txt)
        htmlfile.write(htmlcontents)
        htmlfile.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--template', default='template/template.html')
    parser.add_argument('-s', '--sourcedir', default='pages-textile')
    parser.add_argument('-o', '--outputdir', default='.')
    args = parser.parse_args()
    generate(args.template, args.sourcedir, args.outputdir)


