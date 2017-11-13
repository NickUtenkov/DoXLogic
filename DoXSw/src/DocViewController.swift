//
//  DocViewController.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 06/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class DocViewController : UIViewController
{
	@IBOutlet weak var m_pCardView:UIScrollView!
	@IBOutlet weak var m_pDocInfoHeader:UILabel!
	@IBOutlet weak var m_pDocContactInfo:UILabel!
	@IBOutlet weak var m_pDocket:UILabel!
	@IBOutlet weak var m_pTitle:UILabel!
	@IBOutlet weak var m_pFormalInfo:UILabel!
	@IBOutlet weak var m_rework:UILabel!
	
	@IBOutlet weak var m_pToolBar:UIView!
	
	@IBOutlet weak var m_pBtnApprove:UIButton!
	@IBOutlet weak var m_pBtnResolution:UIButton!
	@IBOutlet weak var m_pBtnReject:UIButton!
	@IBOutlet weak var m_pBtnAssignExecutor:UIButton!

	var m_pWebViewController:WebViewController? = nil
	var m_pCurDoc:DocMO!
	var m_pCurTask:TaskInfo!
	var m_pDummyTaskInfo:TaskInfo? = nil
	private var m_labelPriority:UIImageView!
	private var m_labelDate:UILabel!
	private var m_viewStamp:UIView!
	private var m_currentAttachment = -1,m_attachmentToShow = 0,m_curDocPartIndex = -1
	private var currentViewIdx = 0,returnToViewIdx = 0
	private var m_bIsProcessedList = false
	private var m_pToolBarButtons:[UIView] = []

	private let yBtn:CGFloat = 5
	private let cyBtn:CGFloat = 35
	private var ctxCardView = 0

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if context == &ctxCardView
		{
			//print("CardView size.width",m_pCardView.frame.size.width)
			adjustOrientation()
		}
	}
	
	deinit
	{
		NotificationCenter.`default`.removeObserver(self)
		m_pCardView.removeObserver(self, forKeyPath: "bounds")
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		m_pToolBar.makeGradientGray()
		m_labelPriority = UIImageView(image:UIImage(named:"Urgent.png"))
		m_labelPriority.setOrigin(m_pCardView.bounds.size.width-m_pDocInfoHeader.frame.origin.x-m_labelPriority.frame.size.width,m_pDocInfoHeader.frame.origin.y)
		//m_pCardView.addSubview(m_labelPriority)
		
		let stampImageView = UIImageView(image:UIImage(named:"StampCtrl.png"))
		let width = stampImageView.frame.size.width
		m_labelDate = Utils.createControlDateLabel(stampImageView.frame.size.height,width)
		m_viewStamp = UIView(frame:CGRect(x:0,y:0,w:width,h:stampImageView.frame.size.height+Utils.ControlDateLabelFontSize+4))
		m_viewStamp.addSubview(stampImageView)
		m_viewStamp.addSubview(m_labelDate)
		m_viewStamp.setOrigin(m_pCardView.bounds.size.width-m_pDocInfoHeader.frame.origin.x-width,m_pDocInfoHeader.frame.origin.y)
		//m_pCardView.addSubview(m_viewStamp)

		m_pCardView.isScrollEnabled = true
		m_pCardView.bounces = false
		
		m_pCardView.backgroundColor = ClrDef.clrViewBack1

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Show".localized,style:.plain,target:self,action:#selector(pressedDocPartsPopup))

		m_currentAttachment = -1;
		m_attachmentToShow = 0;
		m_curDocPartIndex = -1;

		m_pBtnApprove.makeGradient(ClrDef.clrAcqu1Green.cgColor,ClrDef.clrAcqu2Green.cgColor)
		m_pBtnReject.makeGradient(ClrDef.clrAcqu1Red.cgColor,ClrDef.clrAcqu2Red.cgColor)
		m_pBtnAssignExecutor.makeGradient(ClrDef.clrAcqu1Blue.cgColor,ClrDef.clrAcqu2Blue.cgColor)
		m_pBtnResolution.makeGradient(ClrDef.clrAcqu1Green.cgColor,ClrDef.clrAcqu2Green.cgColor)

		currentViewIdx = 0
		returnToViewIdx = 0

		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.showDocumentPart), name:NSNotification.Name(rawValue:GlobDat.kDocAttSelected), object:nil)
		
		m_pBtnApprove.isHidden = true
		m_pBtnReject.isHidden = true
		m_pBtnAssignExecutor.isHidden = true
		m_pBtnResolution.isHidden = true

		m_pCardView.addObserver(self, forKeyPath:"bounds", options: .new, context:&ctxCardView)
	}

	override func viewWillAppear(_ animated:Bool)
	{
		super.viewWillAppear(animated)
		if var navTitle = m_pCurDoc.docTitle
		{
			if navTitle.length > 50
			{
				navTitle = String(format:"%@…",String(navTitle.prefix(50)))
			}
			self.navigationItem.title = navTitle
		}
		adjustOrientation()
		showCard()
	}
	
	func tableView(_ tableView: UITableView,numberOfRowsInSection: Int) -> Int
	{//this func needed only to not call other delegate funcs for m_pTableResolutions
		return 0
	}

	func setCardStrings()
	{
		m_pDocInfoHeader.text = m_pCurDoc.documentInfo
		
		var strDocToFrom:String! = "",strDocContact:String? = nil
		if m_pCurDoc.docType == .typeOutput {strDocToFrom = "strDocTo".localized}
		else {strDocToFrom = "strDocFrom".localized}
		
		if m_pCurDoc.docType == .typeInput || isReadingDoc()
		{
			strDocContact = setDocContactInfo(m_pCurDoc.arSenders,true)
		}
		else if m_pCurDoc.docType == .typeOutput
		{
			strDocContact = setDocContactInfo(m_pCurDoc.arRecepients,false)
		}
		else if m_pCurDoc.docType == .typeInternal
		{
			strDocContact = (m_pCurDoc.author?.name)!//nearestOrganization
		}
		
		m_pDocContactInfo.text = ""
		if strDocContact != nil && !strDocContact!.isEmpty
		{
			let dict1 =
				[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr1:NSAttributedString = .init(string:strDocToFrom,attributes:dict1)
			let dict2 =
				[NSAttributedStringKey.font:UIFont(name: "ArialMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr2:NSAttributedString = .init(string:strDocContact!,attributes:dict2)
			let strAttr:NSMutableAttributedString = .init()
			strAttr.append(pStr1)
			strAttr.append(pStr2)
			m_pDocContactInfo.attributedText = strAttr
		}
		
		m_labelPriority.setOrigin(m_pCardView.bounds.size.width-m_pDocInfoHeader.frame.origin.x-m_labelPriority.frame.size.width,m_pDocInfoHeader.frame.origin.y)
		m_labelPriority.isHidden = !m_pCurDoc.priority
		
		let deltaWidth = ((!m_labelPriority.isHidden) ? (m_labelPriority.frame.size.width+5) : 0)
		m_viewStamp.setOrigin(m_pCardView.bounds.size.width-m_viewStamp.bounds.size.width-m_pDocInfoHeader.frame.origin.x-deltaWidth,m_pDocInfoHeader.frame.origin.y)
		m_viewStamp.isHidden = m_pCurDoc.controlStateCode == 0
		
		m_pTitle.text = ""
		if m_pCurDoc.docTitle != nil && !m_pCurDoc.docTitle!.isEmpty
		{
			let dict1 =
				[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr1:NSAttributedString = .init(string:"Тема:",attributes:dict1)
			let dict2 =
				[NSAttributedStringKey.font:UIFont(name: "ArialMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr2:NSAttributedString = .init(string:m_pCurDoc.docTitle!,attributes:dict2)
			let strAttr:NSMutableAttributedString = .init()
			strAttr.append(pStr1)
			strAttr.append(pStr2)
			m_pTitle.attributedText = strAttr
		}

		if let strDocket = m_pCurDoc.docket
		{
			m_pDocket.text = strDocket
		}
		else
		{
			m_pDocket.text = ""
			m_pDocket.setHeight(0)
		}

		m_pFormalInfo.text = ""
		if (isFormalTaskDoc() || isAgreeDoc() || isApprovalDoc()) && (m_pCurTask.taskDescription != nil) 
		{
			let strFormalHeader = String(format:"FormalInfo".localized,(m_pCurTask.author?.name)!,MyDF.dfShortShort.string(from:m_pCurTask.datePlanEnd!),"")
			let dict1 =
				[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr1:NSAttributedString = .init(string:strFormalHeader,attributes:dict1)
			let dict2 =
				[NSAttributedStringKey.font:UIFont(name: "ArialMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr2:NSAttributedString = .init(string:m_pCurTask.taskDescription!,attributes:dict2)
			let strAttr:NSMutableAttributedString = .init()
			strAttr.append(pStr1)
			strAttr.append(pStr2)
			m_pFormalInfo.attributedText = strAttr
		}
		
		m_rework.text = ""
		let bShowReworkReason = (m_pCurTask.reworkReason != nil) || (m_pCurTask.reworkDescription != nil)
		if bShowReworkReason
		{
			var s1 = m_pCurTask.reworkReason
			if s1 == nil {s1 = ""}
			var s2 = m_pCurTask.reworkDescription
			if s2 == nil {s2 = ""}
			let strRework = String(format:"%@. %@",s1!,s2!)

			let dict1 =
				[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.9,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr1:NSAttributedString = .init(string:"На доработку:",attributes:dict1)
			let dict2 =
				[NSAttributedStringKey.font:UIFont(name: "ArialMT", size: 18.0)!,
				 NSAttributedStringKey.foregroundColor:UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0),
				 ]
			let pStr2:NSAttributedString = .init(string:strRework,attributes:dict2)
			let strAttr:NSMutableAttributedString = .init()
			strAttr.append(pStr1)
			strAttr.append(pStr2)
			m_rework.attributedText = strAttr
		}

		if let dt = m_pCurDoc.controlDate {m_labelDate.text = MyDF.dfDateOnly.string(from:dt)}
	}

	func showCard()
	{
		if currentViewIdx != 1
		{
			m_pCardView.isHidden = false
			currentViewIdx = 1
			
			removeWebView()
		}
		returnToViewIdx = 1
		m_currentAttachment = -1
		m_curDocPartIndex = 0
		
		setCardStrings()
		showToolBarButtons()
	}

	func showToolBarButtons()
	{
		m_pToolBarButtons.forEach{$0.isHidden = true}
		m_pToolBarButtons.removeAll()

		if isReadingDoc() || isAcceptExecDoc() {return}

		if isResolutionsDoc() || isExecutionDoc()
		{
			m_pToolBarButtons.append(m_pBtnResolution)
			m_pToolBarButtons.append(m_pBtnAssignExecutor)
		}
		else
		{
			if isAgreeDoc()
			{
				m_pBtnApprove.setTitle("Agreeing".localized,for:.normal)
				m_pBtnReject.setTitle("NotAgreeing".localized,for:.normal)
				m_pToolBarButtons.append(m_pBtnApprove);
				m_pToolBarButtons.append(m_pBtnReject);
			}
			else if isApprovalDoc()
			{
				m_pBtnApprove.setTitle("Approving".localized,for:.normal)
				m_pBtnReject.setTitle("NotApproving".localized,for:.normal)
				m_pToolBarButtons.append(m_pBtnApprove);
				m_pToolBarButtons.append(m_pBtnReject);
			}
			m_pBtnApprove.makeGradient(ClrDef.clrAcqu1Green.cgColor,ClrDef.clrAcqu2Green.cgColor)
			m_pBtnReject.makeGradient(ClrDef.clrAcqu1Red.cgColor,ClrDef.clrAcqu2Red.cgColor)
			m_pToolBarButtons.append(m_pBtnAssignExecutor)
		}
		m_pToolBarButtons.forEach{$0.isHidden = false}
	}

	func showDocumentContent()
	{
		if currentViewIdx != 2
		{
			m_pCardView.isHidden = true
			currentViewIdx = 2
		}
		
		if m_pCurDoc.attachments.count == 0
		{
			showCard()
			return
		}
		
		let pAttInfo = m_pCurDoc.attachments[m_attachmentToShow]
		let b1 = !FileManager.default.fileExists(atPath:Utils.createFilePathString(pAttInfo.fileId))
		if b1 || Utils.getFileSize(pAttInfo.fileId) != pAttInfo.fileSize
		{
			showCard()
			let titl = b1 ? "Error".localized : "Attention".localized
			let msg = b1 ? "DocNotFound".localized : "strCantShowAttachment".localized
			let alrt = UIAlertController(title:titl,message:msg,preferredStyle: .alert)
			let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
			alrt.addAction(okButton)
			present(alrt, animated: true, completion: nil)
			return
		}
		
		returnToViewIdx = 2
		
		if m_currentAttachment == m_attachmentToShow
		{
			//DocContentMO *pAttInfo = [m_pCurrentDocInfo.attachments objectAtIndex:m_attachmentToShow];
			//optimizing(not showing) only non pdf files
			//reshow pdf files for two reasons
			//1. to update(show/not show) rotation buttons
			//2. to not rotateWebView for rotated annotated file 
			return
		}
		
		removeWebView()
		m_pWebViewController = WebViewController()
		self.view.addSubview(m_pWebViewController!.view)
		m_pWebViewController!.view.autoresizingMask = [.flexibleRightMargin , .flexibleWidth , .flexibleBottomMargin , .flexibleHeight]
		m_pWebViewController!.view.clipsToBounds = true
		m_pWebViewController!.view.frame = m_pCardView.frame
		
		m_currentAttachment = m_attachmentToShow
		m_curDocPartIndex = m_attachmentToShow + 1
		
		//DocContentMO *pAttInfo = [m_pCurrentDocInfo.attachments objectAtIndex:m_attachmentToShow];
		if pAttInfo.mime?.lowercased().range(of:"application/pdf") != nil
		{
			self.view.backgroundColor = UIColor(patternImage:UIImage(named:"DocTableBack.png")!)
		}
		else
		{
			self.view.backgroundColor = UIColor.clear
		}
		m_pWebViewController!.setScrollPosition(CGFloat(pAttInfo.scrollPos))
		m_pWebViewController!.show(pAttInfo.fileId,pAttInfo.mime!)

		showToolBarButtons()
	}

	func adjustOrientation()
	{
		m_pToolBar.makeGradientGray()
		if currentViewIdx == 1
		{
			showCard()
		}
		if m_pWebViewController != nil {m_pWebViewController!.view.frame = m_pCardView.frame}
	}

	@objc func showDocumentPart(notification: NSNotification)
	{
		let partIdx = notification.object as! Int
		if partIdx == 0 {showCard()}
		else
		{
			m_attachmentToShow = partIdx-1
			showDocumentContent()
		}
	}

	@IBAction func pressedDocPartsPopup(_ sender: UIButton)
	{
		doPressedDocPartsPopup()
	}

	func doPressedDocPartsPopup()
	{
		let pDocPartsController = DocPartsController()
		pDocPartsController.itemsDocAtt = m_pCurDoc.attachments
		pDocPartsController.selectedAttachment = m_curDocPartIndex
		pDocPartsController.parentWidth = m_pCardView.frame.size.width
		pDocPartsController.strDocAttSelected = GlobDat.kDocAttSelected
		pDocPartsController.updateAttachmentsInfo()
		pDocPartsController.modalPresentationStyle = .popover

		let popover = pDocPartsController.popoverPresentationController!
		popover.sourceView = self.view
		popover.barButtonItem = self.navigationItem.rightBarButtonItem!
		popover.permittedArrowDirections = .up
		
		present(pDocPartsController, animated: true)
	}

	func prepareToShow(_ bProcessed:Bool)
	{
		m_currentAttachment = -1
		m_attachmentToShow = 0
		m_bIsProcessedList = bProcessed
		returnToViewIdx = 0
		//m_pCardView.contentOffset = CGPoint.zero
	}

	func prepareToShowAcqu()
	{
	}

	func removeWebView()
	{
		if m_pWebViewController != nil
		{
			saveAttachmentScrollPosition()
			m_pWebViewController!.view.removeFromSuperview()
			m_pWebViewController!.view = nil
			m_pWebViewController = nil
		}
	}

	func setDocContactInfo(_ arSendersOrRecipients:Array<ContactMO>,_ bIsSenders:Bool) -> String
	{
		var strOut = ""
		let cSenders = arSendersOrRecipients.count
		if cSenders > 0
		{
			var pContact = arSendersOrRecipients[0]
			strOut = pContact.name!
			var strSenders = strOut
			for i in 1..<cSenders
			{
				pContact = arSendersOrRecipients[i]
				let trimmedString = pContact.name!.trimmingCharacters(in: .whitespacesAndNewlines)
				strSenders.append(String(format:",%@",trimmedString))
			}
			strOut = strSenders
		}
		return strOut
	}

	func isResolutionsDoc() -> Bool
	{
		return m_pCurTask.displayEClassId == GlobDat.eClass_DocflowReferencesReviewDocument
	}
	func isExecutionDoc() -> Bool
	{
		return m_pCurTask.displayEClassId == GlobDat.eClass_WorkflowReferencesFormalTask
	}
	func isResOrExecDoc() -> Bool
	{
		return isResolutionsDoc() || isExecutionDoc()
	}
	func isApprovalDoc() -> Bool
	{
		return m_pCurTask.eclassId == GlobDat.eClass_DocflowReferencesApproveDocument
	}
	func isAgreeDoc() -> Bool
	{
		return m_pCurTask.eclassId == GlobDat.eClass_DocflowReferencesAgreeDocument
	}
	func isReadingDoc() -> Bool
	{
		return m_pCurTask.eclassId == GlobDat.eClass_ReadDocument
	}
	func isAcceptExecDoc() -> Bool
	{
		return m_pCurTask.displayEClassId == GlobDat.eClass_AcceptExecution
	}
	func isFormalTaskDoc() -> Bool
	{
		return m_pCurTask.eclassId == GlobDat.eClass_WorkflowReferencesFormalTask
	}

	func saveAttachmentScrollPosition()
	{
	}

	@IBAction func pressedBtnApprove(_ sender: UIButton)
	{
		//self.navigationItem.leftBarButtonItem!.tintColor = UIColor.red//test crashing & its logging
	}
	@IBAction func pressedBtnReject(_ sender: UIButton)
	{
	}
	@IBAction func pressedBtnAssignExecutor(_ sender: UIButton)
	{
	}
	@IBAction func pressedBtnResolution(_ sender: UIButton)
	{
	}
}
