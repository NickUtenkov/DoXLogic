//
//  WebViewController.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 09/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class WebViewController : UIViewController
{
	fileprivate var m_pWebView:UIWebView!
	private var m_pImageView:UIImageView!
	private var m_pScrollView:UIScrollView!
	
	fileprivate var m_pWaitView:UIView!
	fileprivate var m_progress:MBProgressHUD? = nil
	fileprivate var m_bShowingError = false
	fileprivate var m_offsetY:CGFloat = 0
	fileprivate let minZoomScale:CGFloat = 0.5
	fileprivate let maxZoomScale:CGFloat = 7.0

	override func viewDidLoad()
	{
		super.viewDidLoad()

		m_pWebView = UIWebView(frame:self.view.bounds)
		m_pWebView.delegate = self
		m_pWebView.autoresizingMask = [.flexibleRightMargin , .flexibleWidth , .flexibleBottomMargin , .flexibleHeight]

		self.view.backgroundColor = UIColor(patternImage:UIImage(named:"DocTableBack.png")!)
		self.view.autoresizesSubviews = true
		self.view.contentMode = .redraw
		self.view.addSubview(m_pWebView)
		
		m_pImageView = UIImageView(frame:self.view.bounds)
		
		m_pScrollView = UIScrollView(frame:self.view.bounds)
		m_pScrollView.autoresizingMask = [.flexibleRightMargin , .flexibleWidth , .flexibleBottomMargin , .flexibleHeight]
		m_pScrollView.bounces = false
		m_pScrollView.addSubview(m_pImageView)
		self.view.addSubview(m_pScrollView)

		m_pWebView.scrollView.showsVerticalScrollIndicator = true
		m_pWebView.scrollView.showsHorizontalScrollIndicator = true
		m_pWebView.scrollView.indicatorStyle = .black
		m_pWebView.scrollView.isDirectionalLockEnabled = false
		m_pWebView.scrollView.bounces = false
		m_pWebView.scrollView.alwaysBounceVertical = false
		m_pWebView.scrollView.alwaysBounceHorizontal = false
		m_pWebView.scrollView.bouncesZoom = false
		m_pWebView.scalesPageToFit = true

		m_offsetY = 0.0
		
		m_pWaitView = nil

		m_pWebView.backgroundColor = UIColor(patternImage:UIImage(named:"DocTableBack.png")!)
	}

	func show(_ fileId:Int,_ mimeType:String)
	{
		URLCache.shared.removeAllCachedResponses()
		let filePath = Utils.createFilePathString(fileId)
		
		if FileManager.default.fileExists(atPath:filePath)
		{
			if let fileData = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
			{
				if !Utils.isImageMime(mimeType)
				{
					m_pWaitView = UIView(frame:m_pWebView.frame)
					m_pWaitView.backgroundColor = UIColor.white
					
					self.view.addSubview(m_pWaitView)
					self.view.bringSubview(toFront:m_pWaitView)
					
					m_progress = MBProgressHUD(view:m_pWaitView)
					m_pWaitView.addSubview(m_progress!)
					
					m_progress!.label.text = "Loading".localized
					m_progress!.detailsLabel.text = "Document".localized
					m_progress!.bezelView.color = ClrDef.clrAcqu1Blue
					m_progress!.show(animated: true)

					m_pWebView.load(fileData,mimeType:mimeType,textEncodingName:"utf-8",baseURL:URL(string:"http://")!)

					m_pWebView.isHidden = false
					m_pScrollView.isHidden = true
				}
				else
				{
					if let img = UIImage(data:fileData)
					{
						m_pImageView.setWidthHeight(img.size.width,img.size.height)
						m_pScrollView.contentSize = img.size
						m_pImageView.image = img
					}
					m_pWebView.isHidden = true
					m_pScrollView.isHidden = false
				}
			}
			else
			{
				let errMsg = ""//String(format:"ErrorDocShow".localized,[err localizedDescription])
				let alrt = UIAlertController(title:"Error".localized,message:errMsg,preferredStyle: .alert)
				let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
				alrt.addAction(okButton)
				present(alrt, animated: true, completion: nil)
			}
		}
		else
		{
			let alrt = UIAlertController(title:"Error".localized,message:"DocNotFound".localized,preferredStyle: .alert)
			let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
			alrt.addAction(okButton)
			present(alrt, animated: true, completion: nil)
		}
	}

	@objc func loadEmptyPage()
	{
		m_bShowingError = false
		m_pWebView.loadHTMLString("",baseURL:nil)
		URLCache.shared.removeAllCachedResponses()
	}

	func getScrollPosition() -> CGFloat
	{
		return m_pWebView.scrollView.contentOffset.y
	}

	func setScrollPosition(_ offsetY:CGFloat)
	{
		m_offsetY = offsetY
	}
}

extension WebViewController : UIWebViewDelegate
{
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
	{
		return true
	}
	func webViewDidFinishLoad(_ webView: UIWebView)
	{
		//some docs (multi list xls) can issue multiple webViewDidStartLoad/webViewDidFinishLoad commands
		if m_pWaitView != nil
		{
			m_pWaitView.removeFromSuperview()
			m_pWaitView = nil
			m_progress = nil
		}
		
		m_pWebView.scalesPageToFit = true
		m_pWebView.scrollView.minimumZoomScale = minZoomScale
		m_pWebView.scrollView.maximumZoomScale = maxZoomScale
		m_pWebView.scrollView.zoomScale = 1.0
		let yMax = m_pWebView.scrollView.contentSize.height - m_pWebView.frame.size.height
		if m_offsetY > yMax {m_offsetY = yMax}
		m_pWebView.scrollView.contentOffset = CGPoint(x:0,y:m_offsetY)
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
	{
		if m_pWaitView != nil
		{
			m_pWaitView!.removeFromSuperview()
			m_pWaitView = nil
			m_progress = nil
		}
		let errCode = (error as NSError).code
		if errCode != NSURLErrorCancelled
		{
			if !m_bShowingError
			{
				m_bShowingError = true
				m_pWebView.stopLoading()
				var errMsg = error.localizedDescription
				if errCode == 912 {errMsg = "Error912".localized}
				LogFile.shared.writeV("webView:didFailLoadWithError: Error %@ code %d",errMsg,errCode)
				self.performSelector(onMainThread: #selector(self.loadEmptyPage), with:nil, waitUntilDone: false)
				let alrt = UIAlertController(title:"Error".localized,message:errMsg,preferredStyle: .alert)
				let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
				alrt.addAction(okButton)
				present(alrt, animated: true, completion: nil)
			}
		}
	}
}
