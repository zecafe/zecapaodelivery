import { createClient } from '@supabase/supabase-js'
import './media-admin.css'

const sb=createClient('https://yovjbqtazkreruvxoawf.supabase.co','sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor')
const bucket='zecapao-media'
const videoRx=/\.(mp4|webm|mov)(\?.*)?$/i

function toast(msg,error=false){let t=document.querySelector('#mediaToast');if(!t){t=document.createElement('div');t.id='mediaToast';t.className='media-toast';document.body.appendChild(t)}t.textContent=msg;t.className=`media-toast show ${error?'error':''}`;setTimeout(()=>t.classList.remove('show'),2600)}
function safeName(name){return String(name||'arquivo').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9._-]+/g,'-')}
function publicUrl(path){return sb.storage.from(bucket).getPublicUrl(path).data.publicUrl}

async function uploadEntryMedia(input,file){
  const isVideo=file.type.startsWith('video/')
  const limit=isVideo?60:15
  if(file.size>limit*1024*1024){toast(`Arquivo maior que ${limit} MB`,true);return}
  const id=input.dataset.id
  const path=`entrada/${id}/${Date.now()}-${safeName(file.name)}`
  toast(isVideo?'Enviando vídeo…':'Enviando imagem…')
  const {error:up}=await sb.storage.from(bucket).upload(path,file,{cacheControl:'3600',upsert:false,contentType:file.type})
  if(up){toast(up.message,true);return}
  const url=publicUrl(path)
  const {error}=await sb.from('app_entry_config').update({media_url:url,media_type:isVideo?'video':'image',updated_at:new Date().toISOString()}).eq('id',id)
  if(error){toast(error.message,true);return}
  toast('Mídia da entrada publicada ✓')
  const workspace=input.closest('.entry-workspace')
  const preview=workspace?.querySelector('.media-preview')
  if(preview) preview.innerHTML=isVideo?`<video src="${url}" controls muted playsinline></video>`:`<img src="${url}" alt="Prévia">`
}

function enhanceEntry(){
  document.querySelectorAll('input[data-upload][data-table="app_entry_config"]').forEach(input=>{
    input.accept='image/jpeg,image/png,image/webp,video/mp4,video/webm,video/quicktime'
    const box=input.closest('.upload-box')
    const info=box?.querySelector('small')
    if(info&&!info.dataset.enhanced){info.dataset.enhanced='1';info.textContent='1080 × 1920 px · 9:16 · JPG/PNG/WebP ou MP4/WebM · imagem até 15 MB · vídeo até 60 MB'}
  })
  document.querySelectorAll('.entry-workspace .media-preview img').forEach(img=>{
    if(videoRx.test(img.src)){const v=document.createElement('video');v.src=img.src;v.controls=true;v.muted=true;v.playsInline=true;img.replaceWith(v)}
  })
}

document.addEventListener('change',e=>{
  const input=e.target.closest?.('input[data-upload][data-table="app_entry_config"]')
  if(!input)return
  const file=input.files?.[0]
  if(!file)return
  e.preventDefault();e.stopImmediatePropagation()
  uploadEntryMedia(input,file)
},true)

async function uploadLibrary(file){
  const isVideo=file.type.startsWith('video/')
  const limit=isVideo?80:20
  if(file.size>limit*1024*1024){toast(`Arquivo maior que ${limit} MB`,true);return}
  const path=`biblioteca/${Date.now()}-${safeName(file.name)}`
  toast('Enviando para a Biblioteca…')
  const {error}=await sb.storage.from(bucket).upload(path,file,{cacheControl:'3600',upsert:false,contentType:file.type})
  if(error){toast(error.message,true);return}
  toast('Arquivo salvo na Biblioteca ✓')
  await renderLibraryFiles()
}

async function removeLibrary(name){
  if(!confirm('Remover este arquivo da Biblioteca?'))return
  const {error}=await sb.storage.from(bucket).remove([`biblioteca/${name}`])
  if(error){toast(error.message,true);return}
  toast('Arquivo removido')
  await renderLibraryFiles()
}

async function renderLibraryFiles(){
  const host=document.querySelector('#mediaLibraryFiles')
  if(!host)return
  host.innerHTML='<div class="media-loading">Carregando arquivos…</div>'
  const {data,error}=await sb.storage.from(bucket).list('biblioteca',{limit:100,sortBy:{column:'created_at',order:'desc'}})
  if(error){host.innerHTML=`<div class="media-error">${error.message}</div>`;return}
  const files=(data||[]).filter(x=>x.name&&!x.name.endsWith('/'))
  if(!files.length){host.innerHTML='<div class="media-empty">A Biblioteca ainda está vazia.</div>';return}
  host.innerHTML=files.map(f=>{const url=publicUrl(`biblioteca/${f.name}`);const vid=videoRx.test(f.name);return `<article class="media-file-card"><div class="media-file-preview">${vid?`<video src="${url}" muted controls preload="metadata"></video>`:`<img src="${url}" alt="${f.name}" loading="lazy">`}</div><div class="media-file-meta"><b>${f.name}</b><small>${vid?'Vídeo':'Imagem'}</small><div class="media-file-actions"><button data-copy-url="${url}">Copiar URL</button><button class="danger-mini" data-remove-media="${f.name}">Excluir</button></div></div></article>`}).join('')
  host.querySelectorAll('[data-copy-url]').forEach(b=>b.onclick=async()=>{await navigator.clipboard.writeText(b.dataset.copyUrl);toast('URL copiada ✓')})
  host.querySelectorAll('[data-remove-media]').forEach(b=>b.onclick=()=>removeLibrary(b.dataset.removeMedia))
}

function injectLibrary(){
  const panel=[...document.querySelectorAll('.panel')].find(p=>p.querySelector('h2')?.textContent.trim()==='Mídias')
  if(!panel||panel.querySelector('#mediaLibraryAdmin'))return
  const wrap=document.createElement('section')
  wrap.id='mediaLibraryAdmin'
  wrap.className='media-library-admin'
  wrap.innerHTML=`<div class="media-library-hero"><div><span class="media-kicker">BIBLIOTECA CENTRAL</span><h3>Adicionar mídia</h3><p>Faça upload uma vez e use o arquivo em qualquer área do Zé Capão.</p></div><label class="media-big-upload">＋ Adicionar arquivo<input id="libraryUploadInput" type="file" hidden accept="image/jpeg,image/png,image/webp,video/mp4,video/webm,video/quicktime"></label></div><div class="media-spec-grid"><div><b>Tela de Entrada</b><span>1080 × 1920 px · 9:16</span></div><div><b>Banner Home</b><span>1200 × 600 px · 2:1</span></div><div><b>Ícones de categoria</b><span>500 × 500 px · 1:1</span></div><div><b>Logo de parceiro</b><span>800 × 800 px · 1:1</span></div><div><b>Capa / Evento</b><span>1200 × 675 px · 16:9</span></div><div><b>Produto</b><span>1000 × 1000 px · 1:1</span></div></div><div class="media-library-title"><h3>Arquivos da Biblioteca</h3><small>Imagens até 20 MB · vídeos até 80 MB</small></div><div id="mediaLibraryFiles" class="media-library-grid"></div>`
  panel.appendChild(wrap)
  wrap.querySelector('#libraryUploadInput').onchange=e=>{const f=e.target.files?.[0];if(f)uploadLibrary(f)}
  renderLibraryFiles()
}

function enhance(){enhanceEntry();injectLibrary()}
const observer=new MutationObserver(()=>enhance())
observer.observe(document.querySelector('#app'),{childList:true,subtree:true})
enhance()
